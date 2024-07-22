# Jadwiga Swierczynska
# Methods of Classification and Dimensionality Reduction
# Script for testing -- Devices classifier

from classify_devs_330498 import DevicesClassifier, N_COMPONENTS
from hmmlearn import hmm, vhmm
import numpy as np
import matplotlib.pyplot as plt
import os
from tqdm import tqdm
import pandas as pd

DIR_TEST = 'test_folder2'
DIR_CUSTOM_TEST = 'tests'
FILE_TRAIN = 'house3_5devices_train.csv'
SPLIT_RESULTS = 'split_results.txt'

N_ITER = 50
TOL = 1e-4
SEEDS = range(3)
N_TESTS = 100

def split(model : DevicesClassifier):

    with open(SPLIT_RESULTS, 'a') as file:
        file.write('device,ratio,n_components,set,aic,bic,ll\n')

    for dev in tqdm(model.DEVICES):
        print(f"---------- {dev} ----------")
        X = model.train[dev]
        n, _ = X.shape
        print(n)

        for t in range(5, 10):
            train_size = int(n*(t/10))

            ns = range(2, 21)
            X_train = X[:train_size]
            X_test = X[train_size:]

            for n_components in ns:
                print(f"device: {dev}, ratio: {t}, n_components: {n_components}")
                best_ll = None 
                best_model = None 
                for i in range(3):
                    h = hmm.GaussianHMM(n_components=n_components, random_state=i, n_iter=50, tol=1e-4)
                    h.fit(X_train)
                    score = h.score(X_train)
                    if not best_ll or best_ll < score:
                        best_ll = score 
                        best_model = h

                with open(SPLIT_RESULTS, 'a') as file:
                    file.write(f'{dev},{t},{n_components},train,{best_model.aic(X_train)},{best_model.bic(X_train)},{best_model.score(X_train)}\n')
                    file.write(f'{dev},{t},{n_components},test,{best_model.aic(X_test)},{best_model.bic(X_test)},{best_model.score(X_test)}\n')

def plot_split_results(model : DevicesClassifier):
    devs = model.DEVICES

    df = pd.read_csv('split_results.csv')

    for dev in devs:
        df_dev = df[(df['device'] == dev)]
        ns = range(2, 21)
        rs = range(5, 10)


        for set in ['test', 'train']:
            plt.figure()
            for r in rs:
                df_dev_r_set = df_dev[(df_dev['ratio'] == r) & (df_dev['set'] == set) & (df_dev['n_components'] < 21)]
                lls = df_dev_r_set['ll']
                # aic = df_dev_r_set['aic']
                # plt.plot(ns, lls, label=f"{r}0%", marker="o")
                plt.plot(ns, lls, label=f"{r}0%", marker="o")
                

            plt.xticks(ns)
            plt.title(dev+f', score on {set}')
            plt.legend()
            # plt.savefig('plots/'+dev+f'_bigger_{set}_ll_split_plot.png')

    plt.show()


def prepare_tests(model : DevicesClassifier):
    cnt = 1
    model.load_data(DIR_CUSTOM_TEST, FILE_TRAIN)
    correct_answers = {}
    np.random.seed(0)

    for dev in model.DEVICES:
        X = model.train[dev]
        n, _ = X.shape

        for _ in range(N_TESTS):        
            test_length = np.random.randint(1000,n+1)
            test_begin = np.random.randint(0,n-test_length+1)

            test = X[test_begin:test_begin+test_length].reshape(test_length)

            with open(f'tests/dev{"{:03d}".format(cnt)}.csv', 'w') as file:
                file.write('time,dev\n') 

                for t in test:
                    file.write(f'42,{t}\n')
            
            correct_answers[f'dev{"{:03d}".format(cnt)}.csv'] = dev
            
            cnt += 1

    return correct_answers


def score_test(model : DevicesClassifier, correct_answers):
    model.load_data(DIR_CUSTOM_TEST, FILE_TRAIN)

    model.set_hmm()
    model.classify()

    for dev in model.DEVICES:
        cnt = 0
        for file, ans in correct_answers.items():
            if ans == dev and model.answers[file] == dev:
                cnt += 1

        print(f"{dev}, {N_COMPONENTS[dev]}, correctly classified {cnt} out of {N_TESTS}")

    model.write_answer('experiment_results.txt')



def main():
    model = DevicesClassifier()
    # model.load_data(DIR_TEST, FILE_TRAIN)
    correct_answers = prepare_tests(model)
    score_test(model, correct_answers)
    # split(model)
    # plot_split_results(model)
    

if __name__ == "__main__":
    main()
