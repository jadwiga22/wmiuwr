# Jadwiga Swierczynska
# Methods of Classification and Dimensionality Reduction
# Devices classifier (Hidden Markov models)

import argparse
import pandas as pd
import numpy as np
import os
import re
from hmmlearn import hmm


N_COMPONENTS = {
    'lighting2' : 13,
    'lighting4' : 14,
    'lighting5' : 7,
    'refrigerator' : 20,
    'microwave' : 6
}
N_ITER = 50
TOL = 1e-4
SEEDS = range(3)


def parse_args():
    parser = argparse.ArgumentParser(prog="Devices classifier",
                                     description="Project for Methods of Classification and Dimensionality Reduction")
    
    parser.add_argument("-tr", "--train", action="store", required=True, help="File with train data")
    parser.add_argument("-te", "--test", action="store", required=True, help="Directory with test data")
    parser.add_argument("-o", "--output", action="store", required=True, help="File to store the result")
    args = parser.parse_args()
    return vars(args)


class DevicesClassifier:
    DEVICES = ['lighting2', 'lighting5','lighting4', 'refrigerator', 'microwave']

    def __init__(self):
        self.train = {}
        self.test = {}
        self.answers = {}
        self.dev_hmm = {}

    def load_data(self, dir_test, file_train):
        print("Loading data from test and train file...")

        # fetching data from train file        
        df_train = pd.read_csv(file_train)
        rows, cols = df_train.shape

        assert cols == 1 + len(self.DEVICES)
        self.train = {
            dev : df_train[dev].to_numpy().reshape(-1, 1) for dev in self.DEVICES
        }
        
        for dev in self.DEVICES:
            assert len(self.train[dev]) == rows


        # fetching data from test directory  
        for filename in os.listdir(dir_test):
            f = os.path.join(dir_test, filename)

            if os.path.isfile(f) and re.search("dev.*\.csv$", filename):
                print(f'Found file {filename}')

                df_test = pd.read_csv(f)
                self.test[filename] = df_test['dev'].to_numpy().reshape(-1, 1) 

                test_rows, _ = df_test.shape
                assert test_rows == len(self.test[filename])


        print("Done!")
        print("Train data (entires):", rows)
        print("Test data (number of files):", len(self.test))


    def set_hmm(self, components_dict={}):
        # determining the best random seeds & training the models 
        print("Setting up HMMs...")

        for dev in (self.DEVICES):
            if dev in components_dict:
                n_components = components_dict[dev]
            else:
                n_components = N_COMPONENTS[dev]
            X = self.train[dev]
            best_ll = None 
            best_model = None 
            best_seed = None

            # determining the best seed for each of the models
            for s in SEEDS:
                h = hmm.GaussianHMM(n_components=n_components, random_state=s, n_iter=N_ITER, tol=TOL)
                h.fit(X)
                score = h.score(X)
                if not best_ll or best_ll < score:
                    best_ll = score 
                    best_model = h
                    best_seed = s
            print(f"Device: {dev}, best seed: {best_seed}")
            

            self.dev_hmm[dev] = best_model

        print("Done!")


    def classify(self):
        print("Classifying...")

        for file in self.test:
            print(f"Determining device for file {file}")
            X = self.test[file]

            best_score = None 
            best_dev = None

            for dev in self.DEVICES:
                dh = self.dev_hmm[dev]
                score = dh.score(X)
                if not best_score or best_score < score:
                    best_score = score
                    best_dev = dev


            self.answers[file] = best_dev

        print("Done!")

    def write_answer(self, filename_output):
        keys = sorted(list(self.test.keys()))

        with open(filename_output, "w") as file_output:
            file_output.write('file,dev_classified\n')
            for file in keys:
                    file_output.write(file + ',' + self.answers[file] + '\n')



def main():
    args = parse_args()

    model = DevicesClassifier()
    model.load_data(args["test"], args["train"])
    model.set_hmm()
    model.classify()
    model.write_answer(args["output"])


if __name__ == "__main__":
    main()