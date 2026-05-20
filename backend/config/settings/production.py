import os

from .base import *  # noqa: F403,F401

DEBUG = False

ALLOWED_HOSTS = [
    host.strip()
    for host in os.getenv("DJANGO_ALLOWED_HOSTS", "").split(",")
    if host.strip()
]

CHANNEL_LAYERS = {
    "default": {
        "BACKEND": "channels_redis.core.RedisChannelLayer",
        "CONFIG": {
            "hosts": [
                os.getenv("REDIS_URL", "redis://127.0.0.1:6379/0"),
            ],
        },
    },
}
