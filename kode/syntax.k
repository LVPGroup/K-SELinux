module SELINUX-SYNTAX-CORE
    imports BOOL
    imports ID
    imports STRING

    syntax KItem ::= "(" TypeId   TypeId   ClassId ")"
                   | "(" TypeId   WildCard ClassId ")"
                   | "(" WildCard TypeId   ClassId ")"
                   | "(" WildCard WildCard ClassId ")"

    syntax Name ::= Id

    syntax ClassId  ::= Id
    syntax CommonId ::= Id
    syntax PermId   ::= Id
    syntax TypeId   ::= Id
    syntax AttrId   ::= Id
    syntax AliasId  ::= Id
    syntax UserId   ::= Id
    syntax RoleId   ::= Id
    syntax BoolId   ::= Id
    syntax SidId    ::= Id
    syntax CapId    ::= Id

    syntax Context ::= UserId ":" RoleId ":" TypeId
                     | UserId ":" RoleId ":" TypeId ":" Id
    syntax SidStmt ::= "sid" SidId
                     | "sid" SidId Context

    syntax CapStmt ::= "policycap" CapId ";"

    syntax ClassPermPair ::= "(" ClassId PermId ")"

    // name rules
    // XXXIds ::= List{XXXId, ""}
    // XXXs     ::= XXXId | "{" XXXIds "}"
    // XXXList  ::= List{XXXId, ","}

    syntax BoolList ::= List{BoolId, ","}

    syntax ClassIds ::= List{ClassId, ""}
    syntax Classes ::= ClassId | "{" ClassIds "}"

    syntax PermIds ::= List{PermId, ""}
    syntax Perms ::= PermId | "{" PermIds "}"

    syntax TypeIds ::= List{TypeId, ""}
    syntax Types ::= TypeId | "{" TypeIds "}"

    syntax AliasIds ::= List{AliasId, ""}
    syntax Aliases ::= AliasId | "{" AliasIds "}"

    syntax TypeList ::= List{TypeId, ","}
    syntax AttrList ::= List{AttrId, ","}
    syntax UserList ::= List{UserId, ","}
    syntax RoleList ::= List{RoleId, ","}
    
    syntax RoleIds ::= List{RoleId, ""}
    syntax Roles ::= RoleId | "{" RoleIds "}"


    syntax BoolDeclStmt ::= "bool" BoolId Bool ";"
    
    // syntax LogicalOp ::= "&&" | "||" | "^" | "=="  | "!="

    syntax CondExp ::= BoolId
                     | "(" CondExp ")" [bracket]
                     > "!" CondExp
                     > CondExp "&&" CondExp  [left]
                     > CondExp "||" CondExp  [left]
                     > CondExp "==" CondExp  [left]
                     | CondExp "!=" CondExp  [left]

    syntax BoolOp ::= "==" | "!=" | "eq" | "dom" | "domby" | "incomp"
    syntax BoolItem ::= Name BoolOp Name
    
    syntax ConstraintExp ::= BoolItem
                           | "(" ConstraintExp ")"              [bracket]
                           > ConstraintExp "and" ConstraintExp  [left]
                           > ConstraintExp "or"  ConstraintExp  [left]
    

    syntax CommonDeclStmt ::= "common" CommonId "{" PermIds "}"
    
    syntax ClassDeclStmt ::= "class" ClassId

    syntax ClassAccessStmt ::= "class" ClassId "{" PermIds "}"
                             | "class" ClassId "inherits" CommonId
                             | "class" ClassId "inherits" CommonId "{" PermIds "}"

    syntax AttrDeclStmt ::= "attribute" AttrId ";"
    
    syntax TypeDeclStmt ::= "type" TypeId ";"
                          | "type" TypeId "alias" Aliases ";"
                          | "type" TypeId "," AttrList ";"
                          | "type" TypeId "alias" Aliases "," AttrList ";"

    syntax TypeAttrStmt ::= "typeattribute" TypeId AttrList ";"

    syntax TypeAliasStmt ::= "typealias" TypeId "alias" Aliases ";"

    syntax TypeTransition ::= "type_transition" Types Types ":" Classes TypeId ";"
                            | "type_transition" Types Types ":" Classes TypeId String ";"
    
    syntax TypeChangeStmt ::= "type_change" Types Types ":" Classes TypeId ";"
    syntax TypeMemberStmt ::= "type_member" Types Types ":" Classes TypeId ";"

    // user and role
    syntax RoleDeclStmt ::= "role" RoleId ";"
                          | "role" RoleId "types" Types ";"

    syntax AttrRoleStmt ::= "attribute_role" AttrId ";"

    syntax RoleAttrStmt ::= "roleattribute" RoleId AttrId ";"

    syntax RoleAllowStmt ::= "allow" Roles Roles ";"

    syntax RoleTransitionStmt ::= "role_transition" Roles Types RoleId ";"
                                | "role_transition" Roles Types ":" ClassId RoleId ";"

    syntax RoleItem ::= "role" RoleId
    syntax RoleItems ::= List{RoleItem, ";"}
    
    syntax RoleDominance ::= RoleItems "{" RoleDominance "}"
                           | RoleItems ";"

    syntax RoleDomStmt ::= "dominance" "{" RoleDominance "}"
    syntax UserDeclStmt ::= "user" UserId "roles" Roles ";"

    // constrain statement
    syntax ConstrainStmt ::= "constrain" Classes Perms "(" ConstraintExp ")" ";"
    syntax ValidatetransStmt ::= "validatetrans" Classes ConstraintExp ";"


    // if statement
    syntax IfStmt ::= "if" "(" CondExp ")" "{" StmtList "}"
                    | "if" "(" CondExp ")" "{" StmtList "}" "else" "{" StmtList "}"

    syntax OptionalStmt ::= "optional" "{" StmtList "}"


    // access vector
    syntax AccessRule ::= "allow"         [token]
                        | "auditallow"    [token]
                        | "auditdeny"     [token]
                        | "dontaudit"     [token]
                        | "neverallow"    [token]

    syntax WildCard ::= "*" [token]
    
    syntax TypeItem ::= TypeId | "-" TypeId
    syntax TypeItems ::= List{TypeItem, ""}
    syntax TypeItemSet ::= TypeItem
                         | "~" TypeItem
                         | "{" TypeItems "}"
                         | "~" "{" TypeItems "}"
                         | WildCard
                    
    syntax ClassItem ::= ClassId // | "-" ClassName
    syntax ClassItems ::= List{ClassItem, ""}
    syntax ClassItemSet ::= ClassItem
                          | "{" ClassItems "}"
                          | "~" "{" ClassItems "}"
                          | WildCard
    
    syntax PermItem ::= PermId | "-" PermId
    syntax PermItems ::= List{PermItem, ""}
    syntax PermItemSet ::= PermItem
                         | "~" PermItem
                         | "{" PermItems "}"
                         | "~" "{" PermItems "}"
                         | WildCard

    syntax AccessVector ::= AccessRule TypeItemSet TypeItemSet ":" ClassItemSet PermItemSet
    syntax ACStmt ::= AccessVector ";"
    syntax Object ::= TypeId ":" ClassId

    syntax XpermRule ::= "allowxperm"       [token]
                       | "dontauditxperm"   [token]
                       | "auditallowxperm"  [token]
                       | "neverallowxperm"  [token]

    syntax XpermOperation ::= Id
    syntax XpermRuleStmt ::= XpermRule TypeItemSet TypeItemSet ":" ClassItemSet XpermOperation PermItemSet ";"

    // require statement
    syntax RequireStmt ::= "require" "{" RequiredList "}"
                         | "require" RequiredStmt

    syntax RequiredList ::= List{RequiredStmt, ""}
    syntax RequiredStmt ::= RequiredClassStmt
                          | RequiredRoleStmt
                          | RequiredAttrStmt
                          | RequiredUserStmt
                        //   | RequiredSensStmt
                        //   | RequiredCategoryStmt
                          | RequiredTypeStmt
                          | RequiredBoolStmt
                          | RequiredAttrRoleStmt
    
    syntax RequiredClassStmt ::= "class" ClassId ";"
                               | "class" ClassId Perms ";"

    syntax RequiredTypeStmt ::= "type" TypeList ";"
    syntax RequiredAttrStmt ::= "attribute" AttrList ";"
    syntax RequiredUserStmt ::= "user" UserList ";"
    syntax RequiredRoleStmt ::= "role" RoleList ";"
    syntax RequiredBoolStmt ::= "bool" BoolList ";"
    syntax RequiredAttrRoleStmt ::= "attribute_role" AttrId ";"
    // syntax RequiredSensStmt ::= "sensitivity" SensList ";"
    // syntax RequiredCategoryStmt ::= "category" CategoryList ";"

    syntax FsName ::= Id
    syntax NonRootPath ::= List{Id, "/"}
    syntax PartialPath ::= "/" NonRootPath
    syntax GenfsconStmt ::= "genfscon" FsName PartialPath Context

    syntax FsUseTransStmt ::= "fs_use_trans" FsName Context ";"
    syntax FsUseXattrStmt ::= "fs_use_xattr" FsName Context ";"
    syntax FsUseTaskStmt  ::= "fs_use_task"  FsName Context ";"
    
    syntax Protocol ::= "tcp" | "udp" | "sctp"
    syntax PortNumber ::= Int | Int "-" Int
    syntax PortconStmt ::= "portcon" Protocol PortNumber Context

    syntax Stmt ::= RoleDeclStmt
                  | RoleAllowStmt
                  | RoleTransitionStmt
                  | UserDeclStmt
                  | RoleDomStmt
                  | AttrRoleStmt
                  | RoleAttrStmt
                  | TypeDeclStmt
                  | AttrDeclStmt
                  | TypeAttrStmt
                  | TypeAliasStmt
                  | TypeTransition
                  | TypeChangeStmt
                  | TypeMemberStmt
                  | ClassDeclStmt
                  | CommonDeclStmt
                  | ClassAccessStmt
                  | ConstrainStmt
                  | ValidatetransStmt
                  | IfStmt
                  | OptionalStmt
                  | "{" StmtList "}"
                  | BoolDeclStmt
                  | ACStmt
                  | SidStmt
                  | CapStmt
                  | RequireStmt
                  | GenfsconStmt
                  | FsUseTransStmt
                  | FsUseXattrStmt
                  | FsUseTaskStmt
                  | PortconStmt
                  | XpermRuleStmt
                  | ";"

    syntax StmtList ::= List{Stmt, ""}
    
    syntax Pgm ::= List{Stmt, ""}
endmodule

module SELINUX-SYNTAX
    imports SELINUX-SYNTAX-CORE
endmodule