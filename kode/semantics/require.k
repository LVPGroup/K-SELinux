requires "../configuration.k"
requires "../syntax.k"

module REQUIRE
    imports CONFIGURATION
    imports K-EQUAL

    // rule <k> _RS:RequireStmt => . ...</k>
    syntax Controller ::= "require-fail"

    rule <k> require { .RequiredList } => . ...</k>
    rule <k> require { RS:RequiredStmt RL:RequiredList } 
            => require RS ~> require { RL } ...</k>

    rule <k> require-fail ~> R:RequireStmt => . ...</k>
        <require-failed> S:Set => S SetItem(R) </require-failed>

    rule <k> require class C:ClassId ; 
            => #if notBool C in S 
                #then require-fail ~> require class C ;
                #else . #fi
            ...
        </k>
        <classes> S:Set </classes>
    

    rule <k> require class C:ClassId P:PermId ; 
            => #if notBool P in {M[C] orDefault .Set}:>Set
                #then require-fail ~> require class C P ;
                #else . #fi
            ...
        </k>
        <class-perms> M:Map </class-perms>

    rule <k> require class _:ClassId { .PermIds } ; => . ...</k>
    rule <k> require class C:ClassId { P:PermId PS:PermIds } ; 
            => #if notBool P in {M[C] orDefault .Set}:>Set
                #then require-fail ~> require class C P ;
                #else . #fi
            ~> require class C { PS } ;
            ...
        </k>
        <class-perms> M:Map </class-perms>

    rule <k> require role .RoleList ; => . ...</k>
    rule <k> require role R:RoleId , RL:RoleList ;
            => #if notBool R in S
                #then require-fail ~> require role R ;
                #else . #fi
            ~> require role RL ;
            ...
        </k>
        <roles> S:Set => S SetItem(R) </roles>

    rule <k> require type .TypeList ; => . ...</k>
    rule <k> require type T:TypeId , TL:TypeList ;
            => #if notBool T in S
                #then require-fail ~> require type T ;
                #else . #fi
            ~> require type TL ;
            ...
        </k>
        <types> S:Set => S SetItem(T) </types>
    
    rule <k> require attribute .AttrList ; => . ...</k>
    rule <k> require attribute A:AttrId , AL:AttrList ;
            => #if notBool A in S
                #then require-fail ~> require attribute A ;
                #else . #fi
            ~> require attribute AL ;
            ...
        </k>
        <attrs> S:Set => S SetItem(A) </attrs>

    rule <k> require bool .BoolList ; => . ... </k>
    rule <k> require bool B:BoolId, BL:BoolList ; 
            => #if notBool B in_keys(M)
                #then require-fail ~> require bool B ;
                #else . #fi
            ~> require bool BL ;
            ...
        </k>
        <bools> M:Map => M [ B <- M[B] orDefault false ] </bools>

    rule <k> require attribute_role A:AttrId ;
            => #if notBool A in_keys(M)
                #then require-fail ~> require attribute_role A ;
                #else . #fi
            ...
        </k>
        <attr-roles> M:Map => M [ A <- M[A] orDefault .Set ] </attr-roles>

endmodule