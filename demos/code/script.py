import sys
import logging
from pathlib import Path

import pandas as pd


logging.basicConfig(
    level="DEBUG",
    format=(
        "%(asctime)s.%(msecs)03d [%(levelname)s] "
        "%(name)s | %(funcName)s:%(lineno)d | %(message)s"
    ),
    datefmt="%y-%m-%d %H:%M:%S",
    stream=sys.stdout,
)

log = logging.getLogger(__name__)


url = "https://www.envidat.ch/dataset/d6c7a578-6317-49f3-8ba5-71f62b5b6610/resource/0aca99e1-7b3d-492f-a7bb-2756e5b74bbd/download/events.csv"

log.info(f"Reading csv file into dataframe from url: {url}")
df = pd.read_csv(url)

log.info(f"Transposing dataframe {df}")
df = df.transpose()

output_dir = Path(__file__).parent.parent.resolve() / "output"
log.info(f"Creating output dir: {output_dir}")
output_dir.mkdir(parents=True, exist_ok=True)
output_dir.chmod(0o777)

filepath = output_dir / "processed.csv"
log.info(f"Deleting output file if already exists: {filepath}")
filepath.unlink(missing_ok=True)

log.info("Writing output csv to file")
df.to_csv(filepath)
filepath.chmod(0o777)
