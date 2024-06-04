# Jadwiga Swierczynska
# Methods of Classification and Dimensionality Reduction
# Script for testing -- Movies recommendation system

import random
import pandas as pd
from sklearn.model_selection import train_test_split
import numpy as np
from recom_system_330498 import RecommendationSystem
from tqdm import tqdm

FILE_RATINGS = "ratings.csv"
FILE_TEST = "test_ratings.csv"
FILE_TRAIN = "train_ratings.csv"
FILE_VALID_TEST = "test_validation_ratings.csv"
FILE_VALID_TRAIN = "train_validation_ratings.csv"
TYPES = [int, int, float, int]
NUMBER_OF_PARTS = 10
FILE_TEST_RESULTS_NMF = "test_results.txt"
FILE_TEST_RESULTS_SVD1 = "test_results_svd1.txt"
FILE_TEST_RESULTS_SVD2 = "test_results_svd2.txt"
FILE_TEST_RESULTS_SGD = "test_results_sgd.txt"
FILE_TEST_RESULTS_INIT = "test_results_init.txt"
FILE_DEBUG = "debug.txt"

def split_file():
    print("Splitting files...")
    df = pd.read_csv(FILE_RATINGS)
    users = 610

    cols = ",".join(df.columns.values)+"\n"

    with open(FILE_TEST, "w") as file_test:
        with open(FILE_TRAIN, "w") as file_train:
            file_test.write(cols)
            file_train.write(cols)

            for i in range(1, users+1):
                df_usr = df[df.userId == i].to_numpy()
                x_train, x_test = train_test_split(df_usr, test_size=0.9)

                for x in x_train:
                    new_x_train = ",".join([str(t(xi)) for t,xi in zip(TYPES, x)])
                    file_train.write(new_x_train+"\n")

                for x in x_test:
                    new_x_test = ",".join([str(t(xi)) for t,xi in zip(TYPES, x)])
                    file_test.write(new_x_test+"\n")

    print("Done!")


def split_usr_data(df_usr):
    df_usr = df_usr.sample(frac = 1)
    res = []

    for i in range(NUMBER_OF_PARTS):
        res += [df_usr[(i*(len(df_usr) // NUMBER_OF_PARTS)) : ((i+1)*(len(df_usr) // NUMBER_OF_PARTS))]]


    list_idx = random.sample(range(NUMBER_OF_PARTS), k=len(df_usr)-(NUMBER_OF_PARTS)*(len(df_usr) // NUMBER_OF_PARTS))
    for idx, j in zip(list_idx, range((NUMBER_OF_PARTS)*(len(df_usr) // NUMBER_OF_PARTS), len(df_usr))):
        res[idx] = pd.concat([res[idx], df_usr[j:j+1]])

    assert len(df_usr) == sum([len(x) for x in res])
    return res


def cross_val_split_data():
    print("Splitting data for cross-validation...")

    df = pd.read_csv(FILE_RATINGS)
    users = 610
    cols = ",".join(df.columns.values)+"\n"
    dfs = NUMBER_OF_PARTS * [pd.DataFrame()]

    for i in range(1, users+1):
        df_usr = df[df.userId == i]
        df_usr_list = split_usr_data(df_usr)

        for j, d in enumerate(df_usr_list):
            dfs[j] = pd.concat([dfs[j], d])

        assert len(df_usr) == np.sum([len(d) for d in df_usr_list])

    for d in dfs:
        print(d.shape)

    assert len(df) == np.sum([len(x) for x in dfs])
    print("Done!")

    return dfs


def cross_validation_nmf(dfs, params):

    df = pd.read_csv(FILE_RATINGS)
    users = 610
    cols = ",".join(df.columns.values)+"\n"
    
    print("Performing cross-validation...")

    dists = [[].copy() for _ in params]

    for k in tqdm(range(NUMBER_OF_PARTS)):
        with open(FILE_VALID_TRAIN, "w") as file_train:
            with open(FILE_VALID_TEST, "w") as file_test:
                file_test.write(cols)
                file_train.write(cols)
            
                for i in range(1, users+1):
                    x_usr_test = dfs[k][dfs[k].userId == i].to_numpy()
                    ls : list[pd.DataFrame] = [dfs[j][dfs[j].userId == i] for j in range(NUMBER_OF_PARTS) if j != k]
                    x_usr_train = pd.concat(ls).to_numpy()

                    for x in x_usr_train:
                        new_x_train = ",".join([str(t(xi)) for t,xi in zip(TYPES, x)])
                        file_train.write(new_x_train+"\n")

                    for x in x_usr_test:
                        new_x_test = ",".join([str(t(xi)) for t,xi in zip(TYPES, x)])
                        file_test.write(new_x_test+"\n")

        model = RecommendationSystem()
        model.load_data(file_test=FILE_VALID_TEST, file_train=FILE_VALID_TRAIN)
        model.fill_initial_values(nonneg=True)

        for idx, r in enumerate(list(params)):
            model.train_NMF(r)
            res = model.calc_distance()
            dists[idx] += [res]
            print(f"CURRENT RESULT:  k = {k}, r = {r}, res = {res}")


    print("Done!")

    with open(FILE_TEST_RESULTS_NMF, "a") as file_results:
        for idx,r in enumerate(params):
            file_results.write(f"[{r}, {np.mean(dists[idx])}],\n")

    
    return dists


def cross_validation_svd1(dfs, params):
    df = pd.read_csv(FILE_RATINGS)
    users = 610
    cols = ",".join(df.columns.values)+"\n"
    
    print("Performing cross-validation...")

    dists = [[].copy() for _ in params]

    for k in tqdm(range(NUMBER_OF_PARTS)):
        with open(FILE_VALID_TRAIN, "w") as file_train:
            with open(FILE_VALID_TEST, "w") as file_test:
                file_test.write(cols)
                file_train.write(cols)
            
                for i in range(1, users+1):
                    x_usr_test = dfs[k][dfs[k].userId == i].to_numpy()
                    ls : list[pd.DataFrame] = [dfs[j][dfs[j].userId == i] for j in range(NUMBER_OF_PARTS) if j != k]
                    x_usr_train = pd.concat(ls).to_numpy()

                    for x in x_usr_train:
                        new_x_train = ",".join([str(t(xi)) for t,xi in zip(TYPES, x)])
                        file_train.write(new_x_train+"\n")

                    for x in x_usr_test:
                        new_x_test = ",".join([str(t(xi)) for t,xi in zip(TYPES, x)])
                        file_test.write(new_x_test+"\n")

        model = RecommendationSystem()
        model.load_data(file_test=FILE_VALID_TEST, file_train=FILE_VALID_TRAIN)
        model.fill_initial_values(nonneg=True)

        for idx, r in enumerate(list(params)):
            model.train_SVD1(r)
            res = model.calc_distance()
            dists[idx] += [res]
            print(f"CURRENT RESULT:  k = {k}, r = {r}, res = {res}")


    print("Done!")

    with open(FILE_TEST_RESULTS_SVD1, "a") as file_results:
        for idx,r in enumerate(params):
            file_results.write(f"[{r}, {np.mean(dists[idx])}],\n")

    
    return dists

def cross_validation_svd2(dfs, params, n):
    df = pd.read_csv(FILE_RATINGS)
    users = 610
    cols = ",".join(df.columns.values)+"\n"
    
    print("Performing cross-validation...")

    dists = [[].copy() for _ in params].copy()

    for k in tqdm(range(NUMBER_OF_PARTS)):
        with open(FILE_VALID_TRAIN, "w") as file_train:
            with open(FILE_VALID_TEST, "w") as file_test:
                file_test.write(cols)
                file_train.write(cols)
            
                for i in range(1, users+1):
                    x_usr_test = dfs[k][dfs[k].userId == i].to_numpy()
                    ls : list[pd.DataFrame] = [dfs[j][dfs[j].userId == i] for j in range(NUMBER_OF_PARTS) if j != k]
                    x_usr_train = pd.concat(ls).to_numpy()

                    for x in x_usr_train:
                        new_x_train = ",".join([str(t(xi)) for t,xi in zip(TYPES, x)])
                        file_train.write(new_x_train+"\n")

                    for x in x_usr_test:
                        new_x_test = ",".join([str(t(xi)) for t,xi in zip(TYPES, x)])
                        file_test.write(new_x_test+"\n")

        model = RecommendationSystem()
        model.load_data(file_test=FILE_VALID_TEST, file_train=FILE_VALID_TRAIN)
        model.fill_initial_values(nonneg=True)
        model.init_val = model.train.copy()

        for idx, r in enumerate(list(params)):
            ans = model.train_SVD2_aux(r, n)
            dists[idx] += [ans]
            print(f"CURRENT RESULT:  k = {k}, r = {r}, res = {ans[len(ans)-1]}, n = {n}")


    print("Done!")

    with open(FILE_TEST_RESULTS_SVD2, "a") as file_results:
        for i in range(n+1):
            for idx,r in enumerate(params):
                file_results.write(f"[{r}, {np.mean([dists[idx][k][i] for k in range(NUMBER_OF_PARTS)])}, {i}],\n")

    
    return dists

def cross_validation_sgd(dfs, lrs, rs, bs, ep):
    df = pd.read_csv(FILE_RATINGS)
    users = 610
    cols = ",".join(df.columns.values)+"\n"
    
    print("Performing cross-validation...")


    dists = {(l, r, b, e) : [].copy() for l in lrs for r in rs for b in bs for e in range(ep)}

    ks = list(range(NUMBER_OF_PARTS))
    random.shuffle(ks)
    ks = ks[0:3]

    for k in tqdm(ks):
        with open(FILE_VALID_TRAIN, "w") as file_train:
            with open(FILE_VALID_TEST, "w") as file_test:
                file_test.write(cols)
                file_train.write(cols)
            
                for i in range(1, users+1):
                    x_usr_test = dfs[k][dfs[k].userId == i].to_numpy()
                    ls : list[pd.DataFrame] = [dfs[j][dfs[j].userId == i] for j in range(NUMBER_OF_PARTS) if j != k]
                    x_usr_train = pd.concat(ls).to_numpy()

                    for x in x_usr_train:
                        new_x_train = ",".join([str(t(xi)) for t,xi in zip(TYPES, x)])
                        file_train.write(new_x_train+"\n")

                    for x in x_usr_test:
                        new_x_test = ",".join([str(t(xi)) for t,xi in zip(TYPES, x)])
                        file_test.write(new_x_test+"\n")

        model = RecommendationSystem()
        model.load_data(file_test=FILE_VALID_TEST, file_train=FILE_VALID_TRAIN)

        for l in lrs:
            for r in rs:
                for b in bs:
                    res = model.train_SGD(r=r, learning_rate=l, batch_size=b, n_epochs=ep)
                    for e in range(ep):
                        dists[(l, r, b, e)] += [res[e]]
                    print(f"CURRENT RESULT:  k = {k}, lr = {l}, r = {r}, batch_size = {b}, n_epochs = {e}, res = {res}")
                    for idx, re in enumerate(res):
                        print(idx, re)
          


    print("Done!")

    with open(FILE_TEST_RESULTS_SGD, "a") as file_results:
        for l in lrs:
            for r in rs:
                for b in bs:
                    for e in range(ep):
                        file_results.write(f"[{l}, {r}, {b}, {e}, {np.mean(dists[(l, r, b, e)])}],\n")

    
    return dists

def cross_validation_init(dfs):

    df = pd.read_csv(FILE_RATINGS)
    users = 610
    cols = ",".join(df.columns.values)+"\n"
    
    print("Performing cross-validation...")

    init_vals = ['zeros', 'user mean', 'movie mean', 'Pearson']
    dists = [[].copy()  for _ in init_vals]

    for k in tqdm(range(NUMBER_OF_PARTS)):
        with open(FILE_VALID_TRAIN, "w") as file_train:
            with open(FILE_VALID_TEST, "w") as file_test:
                file_test.write(cols)
                file_train.write(cols)
            
                for i in range(1, users+1):
                    x_usr_test = dfs[k][dfs[k].userId == i].to_numpy()
                    ls : list[pd.DataFrame] = [dfs[j][dfs[j].userId == i] for j in range(NUMBER_OF_PARTS) if j != k]
                    x_usr_train = pd.concat(ls).to_numpy()

                    for x in x_usr_train:
                        new_x_train = ",".join([str(t(xi)) for t,xi in zip(TYPES, x)])
                        file_train.write(new_x_train+"\n")

                    for x in x_usr_test:
                        new_x_test = ",".join([str(t(xi)) for t,xi in zip(TYPES, x)])
                        file_test.write(new_x_test+"\n")

        model = RecommendationSystem()
        model.load_data(file_test=FILE_VALID_TEST, file_train=FILE_VALID_TRAIN)

        Z = model.train.copy()
        model.train = Z.copy()
        model.fill_initial_values_zeros(nonneg=True)
        model.approx = model.train.copy()
        res = model.calc_distance()
        dists[0] += [res]


        model.train = Z.copy()
        model.fill_initial_values_user(nonneg=True)
        model.approx = model.train.copy()
        res = model.calc_distance()
        dists[1] += [res]


        model.train = Z.copy()
        model.fill_initial_values_movie(nonneg=True)
        model.approx = model.train.copy()
        res = model.calc_distance()
        dists[2] += [res]


        model.train = Z.copy()
        model.fill_initial_values(nonneg=True)
        model.approx = model.train.copy()
        res = model.calc_distance()
        dists[3] += [res]



    print("Done!")

    with open(FILE_TEST_RESULTS_INIT, "a") as file_results:
        for idx,r in enumerate(init_vals):
            file_results.write(f"{r} [{np.mean(dists[idx])}]\n")

    
    return dists


def test_NMF():
    with open(FILE_TEST_RESULTS_NMF, "a") as file_results:
        file_results.write("\n--- Testing for NMF parameters ---\n\n")

    dfs = cross_val_split_data()
    cross_validation_nmf(dfs, range(50, 51))

def test_SVD1():
    with open(FILE_TEST_RESULTS_SVD1, "a") as file_results:
        file_results.write("\n--- Testing for SVD1 parameters ---\n\n")

    dfs = cross_val_split_data()
    cross_validation_svd1(dfs, range(12, 16))


def test_SVD2():
    with open(FILE_TEST_RESULTS_SVD2, "a") as file_results:
        file_results.write("\n--- Testing for SVD2 parameters ---\n\n")

    dfs = cross_val_split_data()

    cross_validation_svd2(dfs, range(2, 3), 50)


def test_SGD():
    with open(FILE_TEST_RESULTS_SGD, 'a') as file_results:
        file_results.write("\n--- Testing for SGD parameters ---\n\n")

    dfs = cross_val_split_data()

    lrs = [0.001]
    ep = 40
    # lrs = [0.001]
    # rs = range(4,5)
    rs = range(6, 8)
    # bs = [1, 3, 5, 10, 20, 50]
    bs = [1]
    cross_validation_sgd(dfs, lrs=lrs, rs=rs, bs=bs, ep=ep)

def test_init_values():
    with open(FILE_TEST_RESULTS_INIT, 'a') as file_results:
        file_results.write("\n--- Testing for initial values ---\n\n")

    dfs = cross_val_split_data()

    cross_validation_init(dfs)



def main():
    # test_SVD2()
    # test_SVD1()
    # test_NMF()
    # test_init_values()
    test_SGD()

if __name__ == "__main__":
    main()