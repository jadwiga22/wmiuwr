// Jadwiga Swierczynska
// 25.03.2023
// AiSD - pracownia - zadanie B

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

const int MAXN=1e4+5;
const ll INF=1e18;
ll dp[3][MAXN];
int T[3][MAXN];
int Pow[10];
int w,k;

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

int main(){
    Pow[0] = 1;
    FOR(i,1,10){
        Pow[i] = Pow[i-1] * 7;
    }

    scanfast(&w);
    scanfast(&k);

    FOR(j,0,k){
        char a;
        scanfastC(&a);
        T[0][j] = Pow[a - '0'];
        dp[0][j] = T[0][j];
    }

    FOR(j,0,k){
        char a;
        scanfastC(&a);
        T[1][j] = Pow[a - '0'];
        dp[1][j] = -INF;
    }

    FOR(i,2,w){
        char a; 
        int nw = i%3, pw = (i+2)%3, p2w = (i-2)%3;

        scanfastC(&a);
        T[nw][0] = Pow[a - '0'];
        dp[nw][0] = dp[p2w][1] + T[nw][0];

        FOR(j,1,k-1){
            scanfastC(&a);
            T[nw][j] = Pow[a - '0'];
            dp[nw][j] = max(dp[p2w][j-1], dp[p2w][j+1]) + T[nw][j];
                    
        }

        scanfastC(&a);
        T[nw][k-1] = Pow[a - '0'];
        dp[nw][k-1] = dp[p2w][k-2] + T[nw][k-1];


        dp[pw][0] = max(dp[pw][0], dp[nw][2]+T[pw][0]);
        dp[pw][k-1] = max(dp[pw][k-1], dp[nw][k-3]+T[pw][k-1]);

        if(k > 3){
            dp[pw][1] = max(dp[pw][1], dp[nw][3] + T[pw][1]);
            dp[pw][k-2] = max(dp[pw][k-2], dp[nw][k-4]+T[pw][k-2]);
        }

        FOR(j,2,k-2){
            dp[pw][j] = max(dp[pw][j], max(dp[nw][j-2], dp[nw][j+2]) + T[pw][j]);
        }
    }

    ll ans = 0;
    w = (w-1)%3;
    FOR(j,0,k){
        ans = max(ans, dp[w][j]);
    }

    printf("%lld\n", ans);

	return 0;
}