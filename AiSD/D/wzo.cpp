// Jadwiga Swierczynska
// 30.04.2023
// AiSD - pracownia - zadanie D

// Red-Black Tree

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

const ll INF = (ll) 1e18 + 5LL;
const int MAXN = 5e4 + 5;

struct node{
    ll val = INF;
    bool black = true;
    node *p = NULL, *l = NULL, *r = NULL;
};

typedef node* pnode;

node NIL = {INF, true, NULL, NULL, NULL};
pnode root;

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

void RightRotate(pnode x){
    pnode l = x->l, y = l->r;
    x->l = y;

    if(y != &NIL) y->p = x;

    l->p = x->p;
    if(x->p == &NIL){
        root = l;
    }
    else{
        if((x->p)->l == x){
            (x->p)->l = l;
        }
        else{
            (x->p)->r = l;
        }
    }
    l->r = x;
    x->p = l;
}

void LeftRotate(pnode x){
    pnode r = x->r, y = r->l;
    x->r = y;

    if(y != &NIL) y->p = x;

    r->p = x->p;
    if(x->p == &NIL){
        root = r;
    }
    else{
        if((x->p)->l == x){
            (x->p)->l = r;
        }
        else{
            (x->p)->r = r;
        }
    }
    
    r->l = x;
    x->p = r;
    
}

pnode NewNode(ll val = INF){
    pnode v = new node;
    v->val = val;
    v->black = true;
    v->l = &NIL;
    v->r = &NIL;
    v->p = &NIL;
    return v;
}

pnode Insert(ll x){
    pnode v = root, p = v->p;

    while(v != &NIL){
        p = v;
        if(v->val == x){
            return v;
        }
        if(v->val > x){
            v = v->l;
        }
        else{
            v = v->r;
        }
    }

    pnode z = NewNode(x);

    z->p = p;
    if(p == &NIL){
        root = z;
    }
    else{
        if(x < p->val){
            p->l = z;
        }
        else{
            p->r = z;
        }
    }

    return z;
}

pnode LookUp(ll x){
    pnode v = root;
    while(v != &NIL && v->val != x){
        if(v->val > x){
            v = v->l;
        }
        else{
            v = v->r;
        }
    }
    return v;
}

pnode Minimum(pnode x){
    while(x->l != &NIL){
        x = x->l;
    }
    return x;
}

void Transplant(pnode x, pnode y){ // transplant subtree of y to x
    if(x->p == &NIL){
        root = y;
    }
    else{
        if((x->p)->l == x){
            (x->p)->l = y;
        }
        else{
            (x->p)->r = y;
        }
    }
    y->p = x->p;
}


void RBInsert(ll x){
    pnode v = Insert(x);

    v->black = false;

    while(!((v->p)->black)){
        if(v->p == ((v->p)->p)->l){     // father of v is left son of its father
            pnode uncle = ((v->p)->p)->r;
            if(!(uncle->black)){
                (v->p)->black = true;
                uncle->black = true;
                v = (v->p)->p;
                v->black = false;
            }
            else{
                if((v->p)->r == v){
                    v = v->p;
                    LeftRotate(v);
                }
                (v->p)->black = true;
                ((v->p)->p)->black = false;
                RightRotate((v->p)->p);
            }
        }
        else{
            pnode uncle = ((v->p)->p)->l;
            if(!(uncle->black)){
                (v->p)->black = true;
                uncle->black = true;
                v = (v->p)->p;
                v->black = false;
            }
            else{
                if((v->p)->l == v){
                    v = v->p;
                    RightRotate(v);
                }
                (v->p)->black = true;
                ((v->p)->p)->black = false;
                LeftRotate((v->p)->p);
            }
        }
    }

    root->black = true;
}

bool RBDelete(ll xx){
    pnode v = LookUp(xx), y = v, x;
    if(v->val != xx) return false;

    bool black = v->black;

    if(v->l == &NIL){
        x = v->r;
        Transplant(v, v->r);
    }
    else{
        if(v->r == &NIL){
            x = v->l;
            Transplant(v, v->l);
        }
        else{
            y = Minimum(v->r);
            black = y->black;
            x = y->r;
            if(y->p == v){
                x->p = y;
            }
            else{
                Transplant(y, y->r);
                y->r = v->r;
                (y->r)->p = y;
            }
            Transplant(v, y);
            y->l = v->l;
            (y->l)->p = y;
            y->black = v->black;
        }
    }

    delete v;

    if(black){
        while(x != root && x->black){
            if(x == (x->p)->l){
                pnode brother = (x->p)->r;
                if(!(brother->black)){
                    (x->p)->black = false;
                    brother->black = true;
                    LeftRotate(x->p);
                    brother = (x->p)->r;
                }
                else{
                    if((brother->l)->black && (brother->r)->black){
                        brother->black = false;
                        x = x->p;
                    }
                    else{
                        if((brother->r)->black){
                            brother->black = false;
                            (brother->l)->black = true;
                            RightRotate(brother);
                            brother = (x->p)->r;
                        }
                        brother->black = (x->p)->black;
                        (brother->r)->black = true;
                        (x->p)->black = true;
                        LeftRotate(x->p);
                        x = root;
                    }
                }
            }
            else{
                pnode brother = (x->p)->l;

                if(!(brother->black)){
                    (x->p)->black = false;
                    brother->black = true;
                    RightRotate(x->p);
                    brother = (x->p)->l;
                }
                else{
                    if((brother->l)->black && (brother->r)->black){
                        brother->black = false;
                        x = x->p;
                    }
                    else{
                        if((brother->l)->black){
                            brother->black = false;
                            (brother->r)->black = true;
                            LeftRotate(brother);
                            brother = (x->p)->l;
                        }
                        brother->black = (x->p)->black;
                        (brother->l)->black = true;
                        (x->p)->black = true;
                        RightRotate(x->p);
                        x = root;
                    }
                }
            } 
        }
        x->black = true;
    }

    return true;
}

ll RBLower(ll x){
    pnode v = root;
    ll res = -INF;

    while(v != &NIL && v->val != x){
        if(v->val > x){
            v = v->l;
        }
        else{
            res = max(res, v->val);
            v = v->r;
        }
    }

    if(v->val == x) return x;
    return res;
}

ll RBUpper(ll x){
    pnode v = root;
    ll res = INF;

    while(v != &NIL && v->val != x){
        if(v->val > x){
            res = min(res, v->val);
            v = v->l;
        }
        else{
            v = v->r;
        }
    }

    if(v->val == x) return x;
    return res;
}


int main(){
    root = NewNode();
    int n;
    scanfast(&n);

    FOR(i,0,n){
        char ins;
        scanfastC(&ins);

        ll x;
        scanfastLL(&x);

        if(ins == 'I'){
            if(LookUp(x) == &NIL)
                RBInsert(x);
        }

        if(ins == 'D'){
            bool deleted = RBDelete(x);
            if(deleted){
                printf("OK\n");
            }
            else{
                printf("BRAK\n");
            }
        }

        if(ins == 'U'){
            ll res = RBUpper(x);
            if(res == INF){
                printf("BRAK\n");
            }
            else{
                printf("%lld\n", res);
            }
        }

        if(ins == 'L'){
            ll res = RBLower(x);
            if(res == -INF){
                printf("BRAK\n");
            }
            else{
                printf("%lld\n", res);
            }
        }

    }


	return 0;
}