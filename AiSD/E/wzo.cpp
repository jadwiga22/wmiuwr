// Jadwiga Swierczynska
// 05.05.2023
// AiSD - pracownia - zadanie E

#pragma GCC optimize("Ofast","unroll-loops","no-stack-protector")
#include<bits/stdc++.h>
using namespace std;
typedef long long ll;
typedef long double ld;

#define FOR(i,be,en) for(int i=be; i<en; i++)
#define FORD(i,be,en) for(int i=be; i>en; i--)
#define pb push_back
#define vi vector<int>
#define pii pair<int,int>
#define st first
#define nd second
#define vii vector<pii>
#define sz(x) (int)x.size()

const int INF = 1e9 + 5;
const int MAXN = 1e3 + 5;
const int MAXT = 1e5 + 5;

int T[MAXN][MAXN];
pii V[MAXN*MAXN];
int Q[MAXT];
pii rep[MAXN][MAXN];
int sz[MAXN][MAXN];
pii moves[4] = {{-1,0}, {1,0}, {0,-1}, {0,1}};
int ind = 0;
int n, m;
int ans = 0;


void scanfast(int* a){
	register char c=0;
	while(c<33) c=getc_unlocked(stdin);
	int sign=1;
	if(c=='-'){
		sign=-1;
		c=getc_unlocked(stdin);
	}
	(*a)=0;
	while(c>32){
		(*a)=10*(*a)+c-'0';
		c=getc_unlocked(stdin);
	}
	(*a)*=sign;
}

void scanfastLL(ll* a){
	register char c=0;
	while(c<33) c=getc_unlocked(stdin);
	ll sign=1;
	if(c=='-'){
		sign=-1;
		c=getc_unlocked(stdin);
	}
	(*a)=0;
	while(c>32){
		(*a)=10LL*(*a)+c-'0';
		c=getc_unlocked(stdin);
	}
	(*a)*=sign;
}

void scanfastC(char* a){
	register char c=0;
	while(c<33) c=getc_unlocked(stdin);
	(*a)=c;
}

bool cmp(pii x, pii y){
    return T[x.st][x.nd] > T[y.st][y.nd];
}

void Prepare(){
    FOR(i,1,n+1){
        FOR(j,1,m+1){
            rep[i][j] = {i,j};
            sz[i][j] = 1;
        }
    }
}

pii Find(pii x){
    if(rep[x.st][x.nd] != x) rep[x.st][x.nd] = Find(rep[x.st][x.nd]);
    return rep[x.st][x.nd];
}

void Union(pii a, pii b){
    pii x = Find(a), y = Find(b);
    if(x == y) return;
    ans--;
    if(sz[x.st][x.nd] < sz[y.st][y.nd]) swap(x, y);
    sz[x.st][x.nd] += sz[y.st][y.nd];
    rep[y.st][y.nd] = x;
}

void Unlock(pii p, int water){
    ans++;
    FOR(i,0,4){
        if(T[p.st+moves[i].st][p.nd+moves[i].nd] > water){
            Union(p, {p.st+moves[i].st, p.nd+moves[i].nd});
        }        
    }
}


int main(){
    int t;
    scanfast(&n);
    scanfast(&m);

    FOR(i,1,n+1){
        FOR(j,1,m+1){
            scanfast(&T[i][j]);
            V[ind++] = {i, j};
        }
    }

    FOR(i,0,n+2){
        T[i][0] = -1;
        T[i][m+1] = -1;
    }

    FOR(j,0,m+2){
        T[0][j] = -1;
        T[n+1][j] = -1;
    }

    sort(V, V+ind, cmp);
    Prepare();

    scanfast(&t);

    FOR(i,0,t){
        scanfast(&Q[i]);
    }

    int cnt = 0;
    FORD(i,t-1,-1){
        while(T[V[cnt].st][V[cnt].nd] > Q[i]){
            Unlock(V[cnt], Q[i]);
            cnt++;
        }
        Q[i] = ans;
    }
    
    FOR(i,0,t){
        printf("%d ", Q[i]);
    }
    printf("\n");

    return 0;
}