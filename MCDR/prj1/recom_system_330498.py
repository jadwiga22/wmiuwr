# Jadwiga Swierczynska
# Methods of Classification and Dimensionality Reduction
# Movies recommendation system

import argparse
import pandas as pd
import numpy as np
from sklearn.decomposition import NMF, TruncatedSVD
import warnings
from tqdm import tqdm

N_SIMILAR_USERS = 150
R_NMF = 17
R_SVD1 = 14
R_SVD2 = 2
N_ITERATIONS = 47
R_SGD = 6
BATCH_SIZE = 1
LEARNING_RATE = 0.001
N_EPOCHS = 40

def parse_args():
    parser = argparse.ArgumentParser(prog="Recommender system",
                                     description="Project for Methods of Classification and Dimensionality Reduction")
    
    parser.add_argument("-tr", "--train", action="store", required=True, help="File with train data")
    parser.add_argument("-te", "--test", action="store", required=True, help="File with test data")
    parser.add_argument("-a", "--alg", action="store", choices=["NMF", "SVD1", "SVD2", "SGD"], required=True, help="Chosen algorithm")
    parser.add_argument("-r", "--result", action="store", required=True, help="File to store the result")
    args = parser.parse_args()
    return vars(args)

class RecommendationSystem:
    def __init__(self):
        self.test_indices = []
        self.train_indices = []
        self.train = {}
        self.test = {}
        self.approx = {}
        self.usr_sim = {}
        self.train_df = {}
        self.init_val = {}
        self.result = np.nan

    def load_data(self, file_test, file_train):
        print("Loading data from test and train file...")

        # fetching data from file
        df_test = pd.read_csv(file_test)
        df_train = pd.read_csv(file_train)

        # numbering from 0
        df_test["userId"]  -=1
        df_test["movieId"] -=1
        df_train["userId"]  -=1
        df_train["movieId"] -=1

        # sorted lists of distinct movies and users
        list_users = sorted(list(set(list(df_test["userId"]) + list(df_train["userId"]))))
        list_movies = sorted(list(set(list(df_test["movieId"]) + list(df_train["movieId"]))))


        # dictionaries for new numbers of users & movies
        user_number = {
            user : idx for idx, user in enumerate(list_users) 
        }
        movie_number = {
            movie : idx for idx, movie in enumerate(list_movies)
        }

        self.train = np.full((len(list_users), len(list_movies)), fill_value=np.nan)

        self.test = np.full((len(list_users), len(list_movies)), fill_value=np.nan)

        # getting test & train indices (translated)
        self.test_indices = [(user_number[int(row["userId"])], movie_number[int(row["movieId"])]) for _, row in df_test.iterrows()]
        self.train_indices = [(user_number[int(row["userId"])], movie_number[int(row["movieId"])]) for _, row in df_train.iterrows()]

        # filling the train matrix
        for _, row in df_train.iterrows():
            self.train[user_number[int(row["userId"])], movie_number[int(row["movieId"])]] = row["rating"]

        # filling the train matrix
        for _, row in df_test.iterrows():
            self.test[user_number[int(row["userId"])], movie_number[int(row["movieId"])]] = row["rating"]

        print("Done!")
        print("Train data shape:", self.train.shape)
        print("Test data shape:", self.test.shape)

    def fill_initial_values_zeros(self, nonneg=False):
        print("Filling initial values...")
        self.train = np.where(np.isnan(self.train), 0, self.train)
        print("Done!")

    def fill_initial_values_user(self, nonneg=False):
        print("Filling initial values...")
        self.train = np.array([np.where(np.isnan(r), np.nanmean(r), r) for r in self.train])
        print("Done!")

    def fill_initial_values_movie(self, nonneg=False):
        print("Filling initial values...")
        # mean rating of a movie
        self.train = np.array([np.where(np.isnan(r), np.nanmean(r), r) for r in self.train.T]).T
        # mean rating of a user if not found
        self.train = np.array([np.where(np.isnan(r), np.nanmean(r), r) for r in self.train])
        print("Done!")

            
    
    def user_similarity(self):
        print("Calculating user similarities...")

        df = pd.DataFrame(self.train)
        corr = df.T.corr(method="pearson", min_periods=5)
        self.usr_sim = corr.to_numpy()
                
        print("Done!")

    def n_most_similar_users(self, user):
        sims = pd.DataFrame({"val" : self.usr_sim[user,:]})
        sims = sims.sort_values(ascending=False, by="val").head(N_SIMILAR_USERS)
        return sims
    
    def fill_initial_values(self, nonneg=False):
        self.user_similarity()

        print("Filling initial values...")

        n, _ = self.train.shape
        Z = self.train.copy()

        for i in range(n):
            avg = np.nanmean(self.train[i])
            n_most_similar_vec = self.n_most_similar_users(i)
            n_most_similar = np.stack([Z[x] for x, _ in n_most_similar_vec.iterrows()]) 
            
            n_most_similar = (n_most_similar.T - np.nanmean(n_most_similar, axis=1)).T
            n_most_similar_vec = n_most_similar_vec.to_numpy()
            n_most_similar = n_most_similar_vec*n_most_similar

            weights = np.where(~np.isnan(n_most_similar), n_most_similar_vec, n_most_similar)
            weights = np.nansum(np.abs(weights), axis=0)
            

            with warnings.catch_warnings():
                warnings.simplefilter("ignore", category=RuntimeWarning)

                self.train[i] = np.where(np.isnan(self.train[i]) & (weights != 0), avg + np.nansum(n_most_similar, axis=0)/weights, self.train[i])
                self.train[i] = np.where(np.isnan(self.train[i]), np.nanmean(self.train[i]), self.train[i])

                if nonneg:
                    self.train[i] = np.where(self.train[i] < 0, 0, self.train[i])
                      

        print("Done!")


    def calc_distance(self):
        return np.sqrt(np.mean([(self.test[i,j] - self.approx[i,j])**2 for i,j in self.test_indices]))
    

    def train_NMF(self, r=R_NMF):
        print("Training  - NMF...")
        model = NMF(n_components=r, init='random', random_state=0)
        W = model.fit_transform(self.train)
        H = model.components_
        self.approx = np.dot(W, H)    
        self.result = self.calc_distance()
        print("Done!")   

    def train_SVD1(self, r=R_SVD1):
        print("Training  - SVD1...")
        svd = TruncatedSVD(n_components=r , random_state=0, n_iter=10)
        svd.fit(self.train)
        Sigma2 = np.diag(svd.singular_values_)
        VT = svd.components_
        W = svd.transform(self.train)/svd.singular_values_
        H = np.dot(Sigma2, VT)
        self.approx = np.dot(W, H)
        self.result = self.calc_distance()
        print("Done!")  


    def train_SVD2_aux(self, r, n):
        self.train = self.init_val.copy()
        svd = TruncatedSVD(n_components=r , random_state=0)
        svd.fit(self.train)
        Sigma2 = np.diag(svd.singular_values_)
        VT = svd.components_
        W = svd.transform(self.train)/svd.singular_values_
        H = np.dot(Sigma2, VT)
        self.approx = np.dot(W, H)
        
        ans = np.zeros(n+1)
        ans[0] = self.calc_distance()

        for it in range(n):
            print(f"SVD2 : iter {it}...")

            self.train = self.approx.copy()

            for (i,j) in self.train_indices:
                self.train[i,j] = self.init_val[i,j]

            svd = TruncatedSVD(n_components=r, random_state=0)
            svd.fit(self.train)
            Sigma2 = np.diag(svd.singular_values_)
            VT = svd.components_
            W = svd.transform(self.train)/svd.singular_values_
            H = np.dot(Sigma2, VT)
            self.approx = np.dot(W, H)

            # saving answers after each iteration - used only for tests in worker.py!
            ans[it+1] = self.calc_distance()

        print("Done!") 
        return ans


    def train_SVD2(self, r=R_SVD2, n=N_ITERATIONS):
        print("Training  - SVD2...")
        self.fill_initial_values(nonneg=True)
        self.init_val = self.train.copy()
        self.train_SVD2_aux(r, n)
        self.result = self.calc_distance()
        print("Done!")



    def train_SGD(self, r=R_SGD, n_epochs=N_EPOCHS, learning_rate=LEARNING_RATE, batch_size=BATCH_SIZE):
        res = [[].copy() for _ in  range(n_epochs)]

        print("Training  - SGD...")
        n, d = self.train.shape

        W = np.random.random(size=(n, r))*np.sqrt(5/r)
        H = np.random.random(size=(r, d))*np.sqrt(5/r)

        indices = self.train_indices

        for epoch in tqdm(range(n_epochs)):
            np.random.shuffle(indices)
            
            for b in range(0, len(indices), batch_size):
                batch = indices[b:b+batch_size]

                gradW = np.zeros(shape=(n, r))
                gradH = np.zeros(shape=(r, d))

                for (i, j) in batch:                    
                    gradW[i] += (self.train[i,j] - np.dot(W[i], H[:,j]))*(-2)*H[:,j]
                    gradH[:,j] += (self.train[i,j] - np.dot(W[i], H[:,j]))*(-2)*W[i,:]

                W = W - (learning_rate/batch_size)*gradW
                H = H - (learning_rate/batch_size)*gradH

            self.approx = np.dot(W,H)

            # saving results after each iteration - used only for tests in worker.py!
            res[epoch] = self.calc_distance()

        self.approx = np.dot(W,H)
        self.result = self.calc_distance()

        print("Done!")
        return res

    

def main():
    args = parse_args()

    model = RecommendationSystem()
    model.load_data(args["test"], args["train"])

    if args["alg"] == "NMF":
        model.fill_initial_values(nonneg=True)
        model.train_NMF()
    elif args["alg"] == "SVD1":
        model.fill_initial_values(nonneg=True)
        model.train_SVD1()
    elif args["alg"] == "SVD2":
        model.train_SVD2()
    else:
        model.train_SGD()

    with open(args["result"], "w") as file_result:
        file_result.write(str(model.result))   


if __name__ == "__main__":
    main()