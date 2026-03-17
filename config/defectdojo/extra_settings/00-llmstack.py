import os


def _split_csv(raw_value: str) -> list[str]:
    return [item.strip() for item in raw_value.split(",") if item.strip()]


public_host = os.getenv("DEFECTDOJO_PUBLIC_HOST", "defectdojo.llmstack.lan")
allowed_hosts = _split_csv(os.getenv("DD_ALLOWED_HOSTS", public_host))

ALLOWED_HOSTS = allowed_hosts or [public_host]
USE_X_FORWARDED_HOST = True
SECURE_PROXY_SSL_HEADER = ("HTTP_X_FORWARDED_PROTO", "https")
SOCIAL_AUTH_REDIRECT_IS_HTTPS = True
SESSION_COOKIE_SECURE = True
CSRF_COOKIE_SECURE = True

CSRF_TRUSTED_ORIGINS = [
    f"https://{host}"
    for host in ALLOWED_HOSTS
    if host and host not in {"localhost", "127.0.0.1"}
]
