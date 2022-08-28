from pydantic import BaseSettings
import traceback
import logging
from botocore import exceptions

log_format = '%(asctime)s [%(pathname)s:%(lineno)d] [%(name)s] [%(processName)s] [%(levelname)s] %(message)s'
logging.basicConfig(format=log_format, level=logging.INFO)
logger = logging.getLogger(__name__)


def logging_error_exception(e: Exception):
    if (isinstance(e, exceptions.ClientError)):
        logger.error(e.response)
    logger.error("{}\n{}".format(str(e), traceback.format_exc()))

class Environment(BaseSettings):
    data_file: str = "/opt/ml/input/data/training/wiki_100.txt"
    model_file: str = "/opt/ml/model/model.bin"
    wakati_file: str = "/opt/tmp/wakati.txt"

def get_env() -> Environment:
    return Environment()