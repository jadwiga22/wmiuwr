// Jadwiga Swierczynska
// 25.05.2023
// AiSD - pracownia - zadanie F

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
const int MAXN = 1e5 + 5;
const int B = 1 << 18;

struct event{
    int x, y1, y2, val;
};

int T[(B << 1) + 5];
int L[(B << 1) + 5];
event E[(MAXN << 1) + 5];
unordered_map<int, int> Dict;
int Vals[(MAXN << 1) + 5];

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

bool cmp(event a, event b){
    return a.x < b.x || (a.x == b.x && a.val > b.val);
}

void Propagate(int x){
    if(x >= B) return;
    int l = (x << 1), r = l+1;
    L[l] += L[x], L[r] += L[x];
    T[l] += L[x], T[r] += L[x];
    L[x] = 0;
    T[x] = max(T[l], T[r]);
}

void Add(int x, int be, int en, int a, int b, int val){
    if(be == a && en == b){
        T[x] += val;
        L[x] += val;
        return;
    }

    Propagate(x);

    int mid = (be + en) >> 1, l = (x << 1), r = l+1;
    if(a <= mid) Add(l, be, mid, a, min(b, mid), val);
    if(b > mid) Add(r, mid+1, en, max(a, mid+1), b, val);

    T[x] = max(T[l], T[r]);
}


int main(){
    int n;
    scanfast(&n);

    FOR(i,0,n){
        scanfast(&E[(i<<1)].x);
        scanfast(&E[(i<<1)].y1);
        scanfast(&E[(i<<1)+1].x);
        scanfast(&E[(i<<1)].y2);
        scanfast(&E[(i<<1)].val);
        E[(i<<1)+1].y1 = E[(i<<1)].y1;
        E[(i<<1)+1].y2 = E[(i<<1)].y2;
        E[(i<<1)+1].val = -E[(i<<1)].val;
        Vals[(i<<1)] = E[(i<<1)].y1;
        Vals[(i<<1) + 1] = E[(i<<1)].y2;
    }

    sort(Vals, Vals + (n << 1));

    int ind = 0;
    FOR(i,0,(n<<1)){
        Dict.insert({Vals[i], ind});
        ind++;

        while(i+1 < (n<<1) && Vals[i] == Vals[i+1]) 
            i++;
    }

    sort(E, E + (n << 1), cmp);

    int res = 0;

    FOR(i,0,(n<<1)){
        int y1 = Dict[E[i].y1], y2 = Dict[E[i].y2];
        Add(1, 0, B-1, y1, y2, E[i].val);
        res = max(res, T[1]);
    }

    printf("%d\n", res);

    
    return 0;
}