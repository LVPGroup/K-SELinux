requires "../configuration.k"

module CLASS
    imports BOOL
    imports SET
    imports CONFIGURATION

    // class declaration
    rule <k> class C:ClassId => . ...</k>
        <classes> S:Set => S SetItem(C) </classes>
        <class-perms> M:Map => M [C <- .Set] </class-perms>
        requires notBool C in S
    // requires the class undeclared


    // associate a class with a permission list
    rule <k> class C:ClassId { PS:PermIds } => . ...</k>
        <classes> S:Set </classes>
        <class-perms> M:Map => M [C <- PermList2Set(PS)] </class-perms>
        requires C in S
    // requires the class already declared

    // associate a class with a common
    rule <k> class C:ClassId inherits CM:CommonId => . ...</k>
        <common-perms>... CM |-> PERMS:Set ...</common-perms> 
        <classes> CLASSES:Set </classes>
        <commons> COMMONS:Set </commons>
        <class-perms>... C |-> (S:Set => S |Set PERMS) ...</class-perms>
        requires C in CLASSES andBool CM in COMMONS
    // requires the class and the common already declared

    // associate a class with a common and permissons
    rule <k> class C:ClassId inherits CM:CommonId { PS:PermIds } => . ...</k>
        <common-perms>... CM |-> PERMS:Set ...</common-perms>
        <classes> CLASSES:Set </classes>
        <class-perms>
            ... C |-> (S:Set => S |Set PERMS |Set PermList2Set(PS)) ...
        </class-perms>
        <commons> COMMONS </commons>
        requires C in CLASSES andBool CM in COMMONS
    // requires the class and the common already declared


    // common permission statement
    rule <k> common C:CommonId { PS:PermIds } => . ...</k>
        <commons> COMMONS:Set => COMMONS |Set SetItem(C) </commons>
        <common-perms> M:Map => M [ C <- PermList2Set(PS) ] </common-perms>
        requires (notBool C in COMMONS) andBool (notBool C in_keys(M))
    // reuqires the common undeclared

    syntax Set ::= PermList2Set(PermIds) [function]
    rule PermList2Set(.PermIds) => .Set
    rule PermList2Set(P:PermId PS:PermIds) => SetItem(P) |Set PermList2Set(PS)

endmodule