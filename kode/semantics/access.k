requires "../configuration.k"

// module TYPE-UTILS
//     imports CONFIGURATION

//     syntax Bool ::= "canWrite" "(" TypeName "," TypeName ")" [function]
//     // rule canWrite(T1:TypeName, T2:TypeName) => isTrustedType(T1) orBool notBool isTrustedType(T2)
//     rule canWrite(T1:TypeName, T2:TypeName) => TypeCompare(T1, T2)
//     // rule canWrite(_T1:TypeName, _T2:TypeName) => true [owise]

//     syntax Bool ::= "TypeCompare" "(" TypeName "," TypeName ")" [function]
//     rule TypeCompare(_T1:Type2, _T2:Type1) => false
//     rule TypeCompare(_T1:Type3, _T2:Type1) => false
//     rule TypeCompare(_T1:Type4, _T2:Type1) => false
//     rule TypeCompare(_T1:Type3, _T2:Type2) => false
//     rule TypeCompare(_T1:Type4, _T2:Type2) => false
//     rule TypeCompare(_T1:Type4, _T2:Type3) => false
//     rule TypeCompare(_, #token("self", "Id")) => true
//     rule TypeCompare(_, _)                 => true [owise]
// endmodule


module ACCESS
    imports CONFIGURATION
    imports SET
    imports BOOL
    imports MAP
    imports INT
    imports K-EQUAL
    // imports TYPE-UTILS

    syntax Controller ::= "rmDash" | "noDash" | "noSelf"

    rule <k> R:AccessRule T1:TypeItemSet T2:TypeItemSet : { C:ClassId Cs:ClassItems } P:PermItemSet ;
            => R T1 T2 : C P ;
            ~> R T1 T2 : { Cs } P ;
            ...
        </k>
    
    rule <k> _:AccessRule _:TypeItemSet _:TypeItemSet : { .ClassItems } _:PermItemSet ; => . ... </k>
    
    rule <k> R:AccessRule T1:TypeItemSet T2:TypeItemSet : C:ClassId { Ps:PermItems } ;
            => rmDash ~> R T1 T2 : C {Ps} ;
            ...
        </k>
    
    rule <k> R:AccessRule T1:TypeItemSet T2:TypeItemSet : C:ClassId P:PermId ;
            => rmDash ~> R T1 T2 : C P ;
            ...
        </k>

    rule <k> R:AccessRule T1:TypeItemSet T2:TypeItemSet : C:ClassId * ;
            => rmDash 
            ~> R T1 T2 : C { permItemsFromSet({M[C] orDefault .Set}:>Set) } ;
            ...
        </k>
        <class-perms> M:Map </class-perms>

    rule <k> R:AccessRule T1:TypeItemSet T2:TypeItemSet : C:ClassId ~ { Ps:PermItems } ;
            => rmDash 
            ~> R T1 T2 : C { permItemsFromSet({M[C] orDefault .Set}:>Set -Set permItemSet2Set({Ps})) } ;
            ...
        </k>
        <class-perms> M:Map </class-perms>
    
    rule <k> R:AccessRule T1:TypeItemSet T2:TypeItemSet : C:ClassId ~ P:PermId ;
            => rmDash 
            ~> R T1 T2 : C { permItemsFromSet({M[C] orDefault .Set}:>Set -Set SetItem(P)) } ;
            ...
        </k>
        <class-perms> M:Map </class-perms>
    


    rule <k> rmDash 
            ~> R:AccessRule T1:TypeItemSet T2:TypeItemSet : C:ClassId P:PermItemSet ;
            => noDash
            ~> R rmDashType(T1) rmDashType(T2) : C rmDashPerm(P, C) ;
            ...
        </k>

    
    // ------------------- process type ----------------------
    syntax TypeItemSet ::= "rmDashType" "(" TypeItemSet ")" [function]
    rule rmDashType(*) => *
    rule rmDashType(TS:TypeItemSet) => { typeItemsFromSet(resolveDashType(TS)) } [owise]

    syntax TypeItems ::= "typeItemsFromSet" "(" Set ")" [function]
    rule typeItemsFromSet(SetItem(T:TypeId) S:Set) => T typeItemsFromSet(S)
    rule typeItemsFromSet(.Set) => .TypeItems


    syntax Set ::= "resolveDashType" "(" TypeItemSet ")" [function]
    rule [[ resolveDashType(~{ TS:TypeItems }) => TYPES -Set resolveDashType({ TS }) ]]
        <types> TYPES:Set </types>
    rule [[ resolveDashType(~T:TypeId) => TYPES -Set resolveTypeAttr(T) ]]
        <types> TYPES:Set </types>
    rule resolveDashType({ TS:TypeItems }) => getTypeInclusion(TS) -Set getTypeExclusion(TS)
    rule resolveDashType(T:TypeId) => resolveTypeAttr(T)

    // rule resolveDashType(_, _M:Map, _S:Set) => .Set [owise]


    syntax Set ::= "resolveTypeAttr" "(" TypeId ")" [function]
    rule [[ resolveTypeAttr(A:TypeId) => {M[A] orDefault SetItem(A)}:>Set ]]
        <attr-types> M:Map </attr-types>
    rule resolveTypeAttr(_) => .Set [owise]


    syntax Set ::= "getTypeInclusion" "(" TypeItems ")" [function]
    rule getTypeInclusion(T:TypeId Ts:TypeItems)   => resolveTypeAttr(T) |Set getTypeInclusion(Ts)
    rule getTypeInclusion(- _:TypeId Ts:TypeItems) => getTypeInclusion(Ts)
    rule getTypeInclusion(.TypeItems) => .Set 
    rule getTypeInclusion(_) => .Set [owise]


    syntax Set ::= "getTypeExclusion" "(" TypeItems ")" [function]
    rule getTypeExclusion(_:TypeId Ts:TypeItems)   => getTypeExclusion(Ts)
    rule getTypeExclusion(- T:TypeId Ts:TypeItems) => resolveTypeAttr(T) |Set getTypeExclusion(Ts)
    rule getTypeExclusion(.TypeItems) => .Set 
    rule getTypeExclusion(_) => .Set [owise]


    // -------------- process class -----------------
    syntax ClassItemSet ::= "rmDashClass" "(" ClassItemSet ")" [function]
    rule rmDashClass(*) => *
    rule rmDashClass(CS:ClassItemSet) => CS [owise]

    
    // -------------- process permission -----------------
    syntax PermItemSet ::= "rmDashPerm" "(" PermItemSet "," ClassId ")" [function]
    rule rmDashPerm(*, _:ClassId) => *
    rule rmDashPerm(Ps:PermItemSet, C:ClassId)
        => { permItemsFromSet(resolveDashPerm(Ps, C)) } [owise]

    syntax Set ::= "resolveDashPerm" "(" PermItemSet "," ClassId ")" [function]
    rule [[ resolveDashPerm(~{ Ps:PermItems }, C:ClassId)
            => {M[C] orDefault .Set}:>Set -Set resolveDashPerm({Ps}, C) ]]
        <class-perms> M:Map </class-perms>
    rule resolveDashPerm({ P:PermId Ps:PermItems }, C:ClassId)
        => SetItem(P) |Set resolveDashPerm({Ps}, C)
    rule resolveDashPerm({ .PermItems }, _:ClassId) => .Set
    rule resolveDashPerm(P:PermId, _:ClassId) => SetItem(P)
    rule resolveDashPerm(_, _) => .Set [owise]


    // -------------- no dash process ---------------
    rule <k> noDash 
            ~> R:AccessRule { T1:TypeId TS1:TypeItems } TS2:TypeItemSet : C:ClassId PS:PermItemSet ;
            => noDash ~> R T1 TS2 : C PS ;
            ~> noDash ~> R { TS1 } TS2 : C PS ; 
            ...
        </k>
    
    rule <k> noDash
            ~> _:AccessRule { .TypeItems } _:TypeItemSet : _:ClassId _:PermItemSet ;
            => . ...
        </k>

    rule <k> noDash 
            ~> R:AccessRule T1:TypeId { T2:TypeId TS2:TypeItems } : C:ClassId PS:PermItemSet ;
            => noDash ~> R T1 T2 : C PS ; 
            ~> noDash ~> R T1 { TS2 } : C PS ; 
            ...
        </k>
    
    rule <k> noDash 
            ~> _:AccessRule _:TypeId { .TypeItems } : _:ClassId _:PermItemSet ;
            => . ...
        </k>

    // when T1 is *
    rule <k> noDash 
            ~> R:AccessRule * { T2:TypeId TS2:TypeItems } : C:ClassId PS:PermItemSet ;
            => noDash ~> R * T2 : C PS ; 
            ~> noDash ~> R * { TS2 } : C PS ; 
            ...
        </k>
    
    rule <k> noDash 
            ~> _:AccessRule * { .TypeItems } : _:ClassId _:PermItemSet ;
            => . ...
        </k>


    // only read and write
    rule <k> noDash 
            ~> R:AccessRule T1:TypeId T2:TypeId : C:ClassId { P:PermId PS:PermItems } ;
            => #if true // P ==K #token("read", "Id") orBool P ==K #token("write", "Id")
                #then noDash ~> R T1 T2 : C P ;
                #else . #fi
            ~> noDash ~> R T1 T2 : C { PS } ;
            ...
        </k>
    
    rule <k> noDash 
            ~> R:AccessRule T1:TypeId * : C:ClassId { P:PermId PS:PermItems } ;
            => #if true // P ==K #token("read", "Id") orBool P ==K #token("write", "Id")
                #then noDash ~> R T1 * : C P ;
                #else . #fi
            ~> noDash ~> R T1 * : C { PS } ;
            ...
        </k>
    
    rule <k> noDash
            ~> R:AccessRule * T2:TypeId : C:ClassId { P:PermId PS:PermItems } ;
            => #if true // P ==K #token("read", "Id") orBool P ==K #token("write", "Id")
                #then noDash ~> R * T2 : C P ;
                #else . #fi
            ~> noDash ~> R * T2 : C { PS } ;
            ...
        </k>
    
    rule <k> noDash
            ~> R:AccessRule * * : C:ClassId { P:PermId PS:PermItems } ;
            => #if true // P ==K #token("read", "Id") orBool P ==K #token("write", "Id")
                #then noDash ~> R * * : C P ;
                #else . #fi
            ~> noDash ~> R * * : C { PS } ;
            ...
        </k>
    
    rule <k> noDash ~> _:AccessRule _:TypeId _:TypeId : _:ClassId { .PermItems } ; => . ...</k>
    rule <k> noDash ~> _:AccessRule _:TypeId     *    : _:ClassId { .PermItems } ; => . ...</k>
    rule <k> noDash ~> _:AccessRule     *    _:TypeId : _:ClassId { .PermItems } ; => . ...</k>
    rule <k> noDash ~> _:AccessRule     *        *    : _:ClassId { .PermItems } ; => . ...</k>

    // substitute self
    rule <k> noDash
            ~> R:AccessRule T1:TypeId T2:TypeId : C:ClassId P:PermId ;
            => noSelf 
            ~> #if T2 ==K #token("self", "Id") 
                #then R T1 T1 : C P ;
                #else R T1 T2 : C P ;
                #fi 
            ...
        </k>
    
    rule <k> noDash ~> R:AccessRule T1:TypeId * : C:ClassId P:PermId ;
            => noSelf ~> R T1 * : C P ;
            ...
        </k>
    
    rule <k> noDash ~> R:AccessRule * T2:TypeId : C:ClassId P:PermId ;
            => noSelf ~> R * T2 : C P ; 
            ...
        </k>
    
    rule <k> noDash ~> R:AccessRule * * : C:ClassId P:PermId ;
            => noSelf ~> R * * : C P ;
            ...
        </k>


    // allow
    rule <k> noSelf 
            ~> allow T1:TypeId T2:TypeId : C:ClassId P:PermId ;
            => . ...
        </k>
        <allow> L:Set => L |Set SetItem(allow T1 T2 : C P) </allow>
        <domains> S1:Set => S1 |Set SetItem(T1) </domains>
        <objects> S2:Set => S2 |Set SetItem(T2 : C) </objects>

    // neverallow
    // rule <k> noSelf ~> neverallow T1:TypeName T2:TypeName : C:ClassName P:PermName ; => . ... </k>
    //     <neverallow> L:Set => L SetItem(neverallow T1 T2 : C P) </neverallow>
    //     <domains> S1:Set => S1 SetItem(T1) </domains>
    //     <objects> S2:Set => S2 SetItem(T2 : C) </objects>

    rule <k> noSelf ~> neverallow T1:TypeId T2:TypeId : C:ClassId P:PermId ; => . ... </k>
        <neverallow-map>
            M:Map => M [ (T1 T2 C) <- SetItem(P) |Set {M[(T1 T2 C)] orDefault .Set}:>Set ]
        </neverallow-map>
    
    rule <k> noSelf ~> neverallow T1:TypeId * : C:ClassId P:PermId ; => . ... </k>
        <neverallow-map>
            M:Map => M [ (T1 * C) <- SetItem(P) |Set {M[(T1 * C)] orDefault .Set}:>Set ]
        </neverallow-map>
    
    rule <k> noSelf ~> neverallow * T2:TypeId : C:ClassId P:PermId ; => . ... </k>
        <neverallow-map>
            M:Map => M [ (* T2 C) <- SetItem(P) |Set {M[(* T2 C)] orDefault .Set}:>Set ]
        </neverallow-map>
    
    rule <k> noSelf ~> neverallow * * : C:ClassId P:PermId ; => . ... </k>
        <neverallow-map>
            M:Map => M [ (* * C) <- SetItem(P) |Set {M[(* * C)] orDefault .Set}:>Set ]
        </neverallow-map>
    
    // dontaudit
    rule <k> noSelf ~> dontaudit _:TypeId _:TypeId : _:ClassId _:PermId ; => . ... </k>
    
    // auditallow
    rule <k> noSelf ~> auditallow _:TypeId _:TypeId : _:ClassId _:PermId ; => . ... </k>

    // auditdeny
    rule <k> noSelf ~> auditdeny _:TypeId _:TypeId : _:ClassId _:PermId ; => . ... </k>
    

    // ----------------- record allow and neverallow -----------------

    // allow
    // rule <k> noSelf ~> allow T1:TypeName T2:TypeName : C:ClassName PS:PermItemSet ; => . ...</k>
    //     <allow>
    //         M:Map => M [ (T1 T2 C) <- { permItemsFromSet(
    //             permItemSet2Set({M[(T1 T2 C)] orDefault {.PermItems}}:>PermItemSet) |Set permItemSet2Set(PS)
    //         ) } ]
    //     </allow>

    // neverallow
    // rule <k> noSelf ~> neverallow T1:TypeName T2:TypeName : C:ClassName PS:PermItemSet ; => . ...</k>
    //     <neverallow> 
    //         M:Map => M [ (T1 T2 C) <- { permItemsFromSet(
    //             permItemSet2Set({M[(T1 T2 C)] orDefault {.PermItems}}:>PermItemSet) |Set permItemSet2Set(PS)
    //         ) } ]
    //     </neverallow>
    
    // rule <k> noSelf ~> neverallow T1:TypeName * : C:ClassName PS:PermItemSet ; => . ...</k>
    //     <neverallow> M:Map => M [(T1 * C) <- PS] </neverallow>

    // rule <k> noSelf ~> neverallow * T2:TypeName : C:ClassName PS:PermItemSet ; => . ...</k>
    //     <neverallow> M:Map => M [(* T2 C) <- PS] </neverallow>


    // auditallow
    // rule <k> noSelf ~> auditallow _T1:TypeName _T2:TypeName : _C:ClassName _PS:PermItemSet ; => . ...</k>
    //     <auditallow> M => M [(T1 T2 C) <- PS] </auditallow>

    // dontaudit
    // rule <k> noSelf ~> dontaudit _T1:TypeName _T2:TypeName : _C:ClassName _PS:PermItemSet ; => . ...</k>
    //     <dontaudit> M => M [(T1 T2 C) <- PS] </dontaudit>

    // auditdeny
    // rule <k> noSelf ~> auditdeny _T1:TypeName _T2:TypeName : _C:ClassName _PS:PermItemSet ; => . ...</k>
    //     <auditdeny> M => M [(T1 T2 C) <- PS] </auditdeny>



    syntax Set ::= "permItemSet2Set" "(" PermItemSet ")" [function]
    rule permItemSet2Set(P:PermId) => SetItem(P)
    rule permItemSet2Set({P:PermId Ps:PermItems}) => SetItem(P) |Set permItemSet2Set({Ps})
    rule permItemSet2Set({.PermItems}) => .Set
    rule permItemSet2Set(_) => .Set [owise]

    syntax PermItems ::= "permItemsFromSet" "(" Set ")" [function]
    rule permItemsFromSet(SetItem(P:PermId) S:Set) => P permItemsFromSet(S)
    rule permItemsFromSet(.Set) => .PermItems

endmodule