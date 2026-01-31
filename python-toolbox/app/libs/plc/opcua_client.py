from loguru import logger


def connect_opcua(endpoint: str) -> None:
    logger.info("OPC UA client placeholder", endpoint=endpoint)
