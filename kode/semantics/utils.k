requires "../selinux-syntax.k"

// module TYPE-UTILS
//     imports SELINUX-SYNTAX
//     syntax Bool ::= "TypeCompare" "(" TypeName "," TypeName ")" [function]
//     rule TypeCompare(_T1:Type2, _T2:Type1) => false
//     rule TypeCompare(_T1:Type3, _T2:Type1) => false
//     rule TypeCompare(_T1:Type3, _T2:Type2) => false
//     rule TypeCompare(_, _)                 => false [owise]
// endmodule

module UTILS
    imports SET
    imports BOOL

    // resolve a Set from a KItem, usually used for value in a Map
    syntax Set ::= setFromKItem(KItem) [function]
    rule setFromKItem(S:Set) => S
    rule setFromKItem(_)     => .Set [owise]
    // rule setFromKItem(SetItem(K:KItem) S:Set) => SetItem(K) setFromKItem(S)
    // rule setFromKItem(.Set) => .Set


    // syntax Bool ::= isTrustedType(TypeName) [function]
    // rule isTrustedType(_:TrustedTypeName) => true
    // rule isTrustedType(_)                 => false [owise]

endmodule