"""
ASGI config for config project.

It exposes the ASGI callable as a module-level variable named ``application``.

For more information on this file, see
https://docs.djangoproject.com/en/4.2/howto/deployment/asgi/
"""

import os

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings.local')

from django.core.asgi import get_asgi_application

django_asgi_app = get_asgi_application()

from channels.routing import ProtocolTypeRouter, URLRouter
from apps.chat.routing import websocket_urlpatterns
from apps.chat.middleware import FirebaseAuthMiddleware

application = ProtocolTypeRouter({
    'http': django_asgi_app,
    'websocket': FirebaseAuthMiddleware(
        URLRouter(
            websocket_urlpatterns
        )
    ),
})
