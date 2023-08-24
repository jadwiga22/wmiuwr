// Jadwiga Swierczynska
// 04.03.2023
// AiSD - pracownia - zadanie A

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

const int MAXN=1e6+5;

int T[MAXN];

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

void scanfastLL(ll* a){
	register char c=0;
	while(c<33) c=getc_unlocked(stdin);
	(*a)=0;
	ll sign=1;
	if(c=='-'){
		sign=-1;
		c=getc_unlocked(stdin);
	}
	while(c>32){
		(*a)=10LL*(*a)+c-'0';
		c=getc_unlocked(stdin);
	}
	(*a)*=sign;
}

int main(){
	int n;
    scanfast(&n);

    ll sum = 0;
    FOR(i,0,n){
        scanfast(&T[i]);
        sum += T[i];
    }

    ll ans = 0, cur = T[0];
    int en = 1; // w którym miejscu jest teraz drugi browar

    FOR(i,0,n){
        while(min(cur+T[en], sum-cur-T[en]) > cur){
            cur += T[en];
            en = (en+1)%n;
        }
        ans = max(ans, min(cur, sum-cur));
        cur -= T[i];
    }

    printf("%lld\n", ans);
	return 0;
}