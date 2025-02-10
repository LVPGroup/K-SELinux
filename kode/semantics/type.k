requires "../configuration.k"

module TYPE
    imports BOOL
    imports SET
    imports MAP
    imports CONFIGURATION

    // attribute declaration
    rule <k> (attribute A:AttrId ;):AttrDeclStmt => . ...</k>
        <attrs> S:Set => S |Set SetItem(A) </attrs>
        <types> TYPES:Set </types>
        <type-alias> ALIASES:Map </type-alias>
        <attr-types> M:Map => M [A <- .Set] </attr-types>
        requires notBool A in S 
            andBool notBool A in TYPES 
            andBool notBool A in_keys(ALIASES)

    // type declaration
    rule <k> (type T:TypeId ;):TypeDeclStmt => . ...</k>
        <types> S:Set => S |Set SetItem(T) </types>
        <attrs> ATTRS:Set </attrs>
        <type-alias> ALIAS:Map </type-alias>
        requires notBool T in S 
            andBool notBool T in ATTRS 
            andBool notBool T in_keys(ALIAS)
    // Attributes are in the same namespace as types and aliases

    // type declaration with alias
    rule <k> type T:TypeId alias { AS:AliasIds } ; 
            => (type T ;):TypeDeclStmt
            ~> typealias T alias { AS } ;  
        ...</k>

    rule <k> type T:TypeId alias A:AliasId ; => . ...</k>
        <types> TYPES:Set => TYPES |Set SetItem(T) </types>
        <attrs> ATTRS:Set </attrs>
        <type-alias> M:Map => M [ A <- T ] </type-alias>
        requires notBool T in TYPES 
            andBool notBool T in ATTRS 
            andBool notBool T in_keys(M) 
            andBool notBool A in_keys(M)
    

    // type declaration with attribute
    rule <k> type T:TypeId , ( A:AttrId , AS:AttrList => AS ) ; ... </k>
        <types> TYPES:Set </types>
        <attrs> ATTRS:Set </attrs>
        <attr-types>
            M:Map => M [ A <- SetItem(T) |Set {M[A] orDefault .Set}:>Set ]
        </attr-types>
        requires (notBool T in TYPES) andBool (A in ATTRS)
    
    rule <k> type T:TypeId , .AttrList ; => . ...</k>
        <types> S:Set => S |Set SetItem(T) </types>
        <attrs> ATTRS:Set </attrs>
        requires (notBool T in S) andBool (notBool T in ATTRS)


    // type declaration with both attribute and alias
    rule <k> type T:TypeId alias ALIASES:Aliases , ATTRS:AttrList ; 
            => (type T ;):TypeDeclStmt
            ~> typealias T alias ALIASES ;
            ~> typeattribute T ATTRS ;
        ...</k>
    // simply split


    // type alias statement
    rule <k> typealias T:TypeId alias { A:AliasId AL:AliasIds } ; 
            => typealias T alias A ;
            ~> typealias T alias { AL } ;
        ...</k>
    
    rule <k> typealias T:TypeId alias { .AliasIds } ; => . ...</k>
        <types> TYPES:Set </types>
        requires T in TYPES

    rule <k> typealias T:TypeId alias A:AliasId ; => . ...</k>
        <type-alias> M:Map => M [ A <- T ] </type-alias>
        <types> TYPES:Set </types>
        requires T in TYPES andBool notBool A in_keys(M)


    // type attribute statement
    // implicitly requires attribute defined
    rule <k> typeattribute T:TypeId ( A:AttrId , AL:AttrList => AL ) ; ... </k>
        <types> TYPES:Set </types>
        <attr-types>
            M:Map => M [ A <- SetItem(T) |Set {M[A] orDefault .Set}:>Set ]
        </attr-types>
        requires T in TYPES

    rule <k> typeattribute _T:TypeId .AttrList ; => . ...</k>


    // type transition
    rule <k> type_transition _:Types _:Types : _:Classes _:TypeId ; => . ... </k>
    rule <k> type_transition _:Types _:Types : _:Classes _:TypeId _:String ; => . ... </k>
    rule <k> type_change _:Types _:Types : _:Classes _:TypeId ; => . ... </k>
    rule <k> type_member _:Types _:Types : _:Classes _:TypeId ; => . ... </k>


    syntax Set ::= AttrList2Set(AttrList) [function]
    rule AttrList2Set(.AttrList) => .Set
    rule AttrList2Set(A:AttrId , AS:AttrList) => SetItem(A) |Set AttrList2Set(AS)
    
endmodule