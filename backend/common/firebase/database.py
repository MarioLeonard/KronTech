"""Firebase Firestore database integration for data persistence."""

import logging
from typing import Any, Dict, List, Optional

import firebase_admin
from firebase_admin import credentials, firestore
from django.conf import settings
from google.cloud import firestore as cloud_firestore
from google.cloud.firestore_v1.base_query import FieldFilter
from google.oauth2 import service_account

logger = logging.getLogger(__name__)


class FirestoreService:
    """Service for Firestore database operations."""

    _instance = None
    _db = None

    def __new__(cls):
        """Implement singleton pattern."""
        if cls._instance is None:
            cls._instance = super().__new__(cls)
        return cls._instance

    def __init__(self):
        """Initialize Firestore client."""
        if self._db is None:
            self._initialize_firestore()

    @staticmethod
    def _initialize_firestore():
        """Initialize Firestore client."""
        try:
            if not firebase_admin._apps:
                firebase_creds_path = getattr(
                    settings,
                    "FIREBASE_CREDENTIALS_PATH",
                    None,
                )
                if not firebase_creds_path:
                    raise Exception("FIREBASE_CREDENTIALS_PATH not configured")
                cred = credentials.Certificate(firebase_creds_path)
                firebase_admin.initialize_app(cred)
            database_id = getattr(settings, "FIRESTORE_DATABASE_ID", "(default)")
            if database_id == "(default)":
                FirestoreService._db = firestore.client()
            else:
                google_credentials = (
                    service_account.Credentials.from_service_account_file(
                        settings.FIREBASE_CREDENTIALS_PATH
                    )
                )
                FirestoreService._db = cloud_firestore.Client(
                    project=google_credentials.project_id,
                    credentials=google_credentials,
                    database=database_id,
                )
            logger.info("Firestore client initialized successfully")
        except Exception as e:
            logger.error(f"Failed to initialize Firestore: {e}")
            raise

    @staticmethod
    def get_document(collection: str, document_id: str) -> Optional[Dict]:
        """
        Get a single document from Firestore.

        Args:
            collection: Collection name
            document_id: Document ID

        Returns:
            Document data as dict or None if not found
        """
        try:
            doc = FirestoreService._db.collection(collection).document(
                document_id
            ).get()
            if doc.exists:
                return {"id": doc.id, **doc.to_dict()}
            return None
        except Exception as e:
            logger.error(f"Error getting document {document_id} from {collection}: {e}")
            raise

    @staticmethod
    def get_documents(
        collection: str,
        filters: Optional[List[tuple]] = None,
        limit: Optional[int] = None,
    ) -> List[Dict]:
        """
        Get multiple documents from Firestore with optional filters.

        Args:
            collection: Collection name
            filters: List of tuples (field, operator, value)
            limit: Maximum number of documents to return

        Returns:
            List of documents
        """
        try:
            query = FirestoreService._db.collection(collection)

            if filters:
                for field, operator, value in filters:
                    query = query.where(filter=FieldFilter(field, operator, value))

            if limit:
                query = query.limit(limit)

            docs = query.stream()
            return [{"id": doc.id, **doc.to_dict()} for doc in docs]
        except Exception as e:
            logger.error(
                f"Error getting documents from {collection} with filters {filters}: {e}"
            )
            raise

    @staticmethod
    def set_document(
        collection: str,
        document_id: str,
        data: Dict[str, Any],
        merge: bool = True,
    ) -> bool:
        """
        Set or update a document in Firestore.

        Args:
            collection: Collection name
            document_id: Document ID
            data: Document data
            merge: If True, merge with existing data; if False, overwrite

        Returns:
            True if successful
        """
        try:
            FirestoreService._db.collection(collection).document(
                document_id
            ).set(data, merge=merge)
            logger.info(f"Document {document_id} set in {collection}")
            return True
        except Exception as e:
            logger.error(f"Error setting document {document_id} in {collection}: {e}")
            raise

    @staticmethod
    def update_document(
        collection: str,
        document_id: str,
        data: Dict[str, Any],
    ) -> bool:
        """
        Update specific fields in a document.

        Args:
            collection: Collection name
            document_id: Document ID
            data: Fields to update

        Returns:
            True if successful
        """
        try:
            FirestoreService._db.collection(collection).document(
                document_id
            ).update(data)
            logger.info(f"Document {document_id} updated in {collection}")
            return True
        except Exception as e:
            logger.error(
                f"Error updating document {document_id} in {collection}: {e}"
            )
            raise

    @staticmethod
    def delete_document(collection: str, document_id: str) -> bool:
        """
        Delete a document from Firestore.

        Args:
            collection: Collection name
            document_id: Document ID

        Returns:
            True if successful
        """
        try:
            FirestoreService._db.collection(collection).document(
                document_id
            ).delete()
            logger.info(f"Document {document_id} deleted from {collection}")
            return True
        except Exception as e:
            logger.error(
                f"Error deleting document {document_id} from {collection}: {e}"
            )
            raise

    @staticmethod
    def batch_write(
        operations: List[Dict[str, Any]],
    ) -> bool:
        """
        Perform multiple write operations in a batch.

        Args:
            operations: List of operations with keys: operation (set/update/delete),
                       collection, document_id, and optionally data

        Returns:
            True if successful
        """
        try:
            batch = FirestoreService._db.batch()

            for op in operations:
                operation = op.get("operation")
                collection = op.get("collection")
                document_id = op.get("document_id")
                doc_ref = FirestoreService._db.collection(collection).document(
                    document_id
                )

                if operation == "set":
                    batch.set(doc_ref, op.get("data"), merge=op.get("merge", True))
                elif operation == "update":
                    batch.update(doc_ref, op.get("data"))
                elif operation == "delete":
                    batch.delete(doc_ref)

            batch.commit()
            logger.info(f"Batch write completed with {len(operations)} operations")
            return True
        except Exception as e:
            logger.error(f"Error performing batch write: {e}")
            raise
