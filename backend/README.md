# Backend Django

Acest folder contine backend-ul proiectului, construit cu Django.

## Arhitectura curenta

```text
backend/
├── .venv/
├── apps/
│   ├── core/
│   │   └── migrations/
│   └── tourism/
│       └── migrations/
├── common/
│   ├── api/
│   ├── firebase/
│   ├── services/
│   └── utils/
├── config/
│   └── settings/
├── media/
├── requirements/
├── staticfiles/
├── templates/
├── .env.example
├── .gitignore
├── manage.py
└── README.md
```

## Ce exista acum in proiect

- proiect Django functional
- configurare separata pe medii prin `config/settings/base.py`, `local.py` si `production.py`
- ruta de verificare la `/api/health/`
- aplicatia `core` conectata in proiect
- aplicatia `tourism` conectata in proiect
- foldere separate pentru cod comun, template-uri, fisiere statice si media
- mediu virtual local in `.venv`

## Rolul fiecarui folder

### `.venv/`

Contine mediul virtual Python al proiectului. Aici sunt instalate dependintele locale, inclusiv Django.

### `apps/`

Contine aplicatiile Django din proiect. Fiecare aplicatie grupeaza fisierele necesare pentru o zona logica din backend.

### `apps/core/`

Contine aplicatia de baza a proiectului.

Rolul fisierelor existente:

- `apps.py` defineste configurarea aplicatiei pentru Django
- `views.py` contine view-ul `health_check`
- `urls.py` defineste ruta `health/`
- `tests.py` contine testul pentru endpoint-ul de health-check
- `models.py` exista ca fisier standard pentru modele Django, dar in acest moment nu contine modele
- `admin.py` exista ca fisier standard pentru integrarea cu Django Admin
- `migrations/` pastreaza migrarile bazei de date pentru aceasta aplicatie

### `apps/tourism/`

Contine o aplicatie Django separata, deja inregistrata in proiect.

Rolul fisierelor existente:

- `apps.py` defineste configurarea aplicatiei pentru Django
- `models.py`, `views.py`, `urls.py`, `tests.py` si `admin.py` exista deja in structura aplicatiei
- `migrations/` este folderul pentru migrarile acestei aplicatii

In momentul actual, fisierele din aceasta aplicatie sunt placeholder-e structurale si nu contin logica de business.

### `common/`

Contine cod comun reutilizabil la nivel de proiect.

### `common/api/`

Contine componente comune pentru zona de API. In prezent exista fisierul `responses.py`.

### `common/firebase/`

Contine fisiere dedicate zonei Firebase:

- `auth.py`
- `database.py`
- `exceptions.py`
- `types.py`

Aceste fisiere exista in proiect ca parte din arhitectura actuala si sunt organizate separat in acelasi loc.

### `common/services/`

Folder rezervat pentru servicii comune. In acest moment contine doar fisierul `__init__.py`.

### `common/utils/`

Folder pentru utilitare comune. In acest moment contine doar fisierul `__init__.py`.

### `config/`

Contine configurarea principala a proiectului Django.

Rolul fisierelor existente:

- `urls.py` defineste rutele de nivel de proiect
- `asgi.py` expune configurarea ASGI
- `wsgi.py` expune configurarea WSGI
- `settings/` contine setarile aplicatiei impartite pe fisiere

### `config/settings/`

Contine setarile proiectului:

- `base.py` contine configurarea comuna
- `local.py` contine configurarea locala
- `production.py` contine configurarea pentru productie
- `__init__.py` marcheaza folderul ca pachet Python

### `media/`

Folder pentru fisiere media generate sau incarcate de aplicatie.

### `requirements/`

Contine fisierele cu dependintele proiectului.

- `base.txt` include dependintele Python folosite acum in backend

### `staticfiles/`

Folder pentru fisiere statice colectate de Django.

### `templates/`

Folder pentru template-uri Django la nivel de proiect.

## Rolul fisierelor din radacina

### `.env.example`

Exemplu de variabile de mediu folosite de proiect.

### `.gitignore`

Lista de fisiere si foldere care nu trebuie urcate in Git, cum ar fi `.venv`, `db.sqlite3` sau cache-ul Python.

### `manage.py`

Punctul principal de rulare pentru comenzile Django.

Exemple:

```bash
python manage.py runserver
python manage.py check
python manage.py test
```

### `README.md`

Documentatia backend-ului.

## Rute existente

In acest moment exista urmatoarele rute definite:

- `/admin/`
- `/api/health/`

## Pornire locala

Din folderul `backend`:

```bash
source .venv/bin/activate
python manage.py migrate
python manage.py runserver
```

## Verificare

Comenzi utile pentru verificare:

```bash
python manage.py check
python manage.py test
```
