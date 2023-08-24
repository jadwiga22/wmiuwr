// Jadwiga Swierczynska
// 18.04.2023
// AiSD - pracownia - zadanie C

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

const int MAXN = 1e5+5;
const int MAXM = 2e6+5;
const int INF = 1e9+5;

int d[MAXN];
bool vis[MAXN];
int be[MAXN];
int en[MAXN];
ll Edges[MAXM];
int Heap[MAXN];
int pos[MAXN];
int N = 1;

struct edge{
    int a,b,c;
};

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

void scanfastC(char* a){
	register char c=0;
	while(c<33) c=getc_unlocked(stdin);
	(*a)=c;
}

ll Compress(int a, int b, int c){
    return ((1LL * a) << 40) + ((1LL * b) << 20) + c;
}

edge Decompress(ll x){
    return {(x & ~(0xffffffffffLL)) >> 40, (x & 0x000000fffff00000LL) >> 20, (x & 0xfffff)};
}

bool Greater(int a, int b){
    return d[Heap[a]] < d[Heap[b]];
}

void MoveDown(int i){
    int k = i, j;
    do{
        j = k;
        if(2*j <= N && Greater(2*j, k)) k = 2*j;
        if(2*j < N && Greater(2*j+1, k)) k = 2*j + 1;
        swap(Heap[j], Heap[k]);
        swap(pos[Heap[j]], pos[Heap[k]]);
    }while(j != k);
}

void MoveUp(int i){
    int k = i, j;
    do{
        j = k;
        if(j > 1 && Greater(k, j >> 1)) k = j >> 1;
        swap(Heap[j], Heap[k]);
        swap(pos[Heap[j]], pos[Heap[k]]);
    }while(j != k);
}

void Change(int i, int x){
    int p = pos[i], u = d[i];
    d[i] = x;
    if(u < x) MoveDown(p);
    else MoveUp(p);
}

void BuildHeap(int n){
    FOR(i,1,n+1){
        Heap[i] = i;
        pos[i] = i;
    }
    N = n;
    FORD(i, n >> 1, 0){
        MoveDown(i);
    }
}

int GetMin(){
    return Heap[1];
}

void DeleteMin(){
    swap(Heap[1], Heap[N]);
    swap(pos[Heap[1]], pos[Heap[N]]);
    N--;
    MoveDown(1);
}

void Dijkstra(int n){
    FOR(i,2,n+1){
        d[i] = INF;
    }

    BuildHeap(n);

    while(N){
        int v = GetMin();
        DeleteMin();
        if(vis[v]) continue;
        vis[v] = true;

        for(int i = be[v]; i <= en[v]; i++){
            edge e = Decompress(Edges[i]);
            if(d[e.b] > d[v] + e.c){
                Change(e.b, d[v] + e.c);
            }
        }
    }
}


int main(){
    int n,m,k;
    scanfast(&n);
    scanfast(&m);
    scanfast(&k);

    FOR(i,0,m){
        int a,b,c;
        scanfast(&a);
        scanfast(&b);
        scanfast(&c);
        Edges[2*i] = Compress(a,b,c);
        Edges[2*i + 1] = Compress(b,a,c);
    }

    sort(Edges, Edges + 2*m);

    FOR(i,1,n+1){
        be[i] = -1;
        en[i] = -2;
    }

    FOR(i,0,2*m){
        edge e = Decompress(Edges[i]);
        if(be[e.a] == -1) be[e.a] = i;
        en[e.a] = i;
    }

    Dijkstra(n);

    ll ans = 0;

    FOR(i,0,k){
        int a;
        scanfast(&a);
        if(d[a] == INF){
            printf("NIE\n");
            return 0;
        }
        ans += d[a];
    }

    printf("%lld\n", 2*ans);


	return 0;
}