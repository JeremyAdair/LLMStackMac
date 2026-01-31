import time


def sleep_until(next_run: float, stop_flag: callable) -> float:
    while True:
        now = time.monotonic()
        if stop_flag():
            return now
        if now >= next_run:
            return now
        time.sleep(min(0.1, next_run - now))
