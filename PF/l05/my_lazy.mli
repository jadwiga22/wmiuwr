type 'a my_lazy

val force : 'a my_lazy -> 'a

val fix : ('a my_lazy -> 'a) -> 'a my_lazy