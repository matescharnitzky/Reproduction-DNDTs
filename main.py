
# 1. Environment setup --------------------------

# packages
import pandas as pd
import importlib

# config
import config.config as config
importlib.reload(config)

# user-defined modules


# 2. read data ----------------------------------

iris_df = pd.read_csv(config.iris, header=None)
haberman_df = pd.read_csv(config.haberman, header=None)
car_df = pd.read_csv(config.car, header=None)
titanic_df = pd.read_csv(config.titanic)
cancer_df = pd.read_csv(config.breast_cancer_wisconsin, header=None)
diabetes_df = pd.read_csv(config.pima_indians_diabetes)
gms_credit_df = pd.read_csv(config.titanic)
poker_df = pd.read_csv(config.poker_hand, header=None)
flight_df = pd.read_csv(config.flight_delays)
hr_df = pd.read_csv(config.hr)
g_credit_df = pd.read_csv(config.german_credit)
connect_df = pd.read_csv(config.connect, header=None)
image_df = pd.read_csv(config.image_segmentation, header=None)
covertype_df = pd.read_csv(config.covertype, header=None)
