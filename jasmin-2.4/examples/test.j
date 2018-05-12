.source test.j
.class public examples/test
.super java/lang/Object

.method public <init>()V
aload_0
invokenonvirtual java/lang/Object/<init>()V
return
.end method

.method public static main([Ljava/lang/String;)V
.limit locals 100
.limit stack 100
iconst_0
istore 1
fconst_0
fstore 2
.line 1
iconst_0
istore 3
.line 2
L_0:
iconst_0
istore 4
.line 3
.line 4
L_1:
ldc 5
istore 3
L_2:
iload 3
ldc 0
if_icmpgt L_4
goto L_5
L_3:
iload 3
ldc 1
iadd
istore 3
goto L_2
L_4:
.line 5
.line 6
iload 4
ldc 5
iadd
istore 4
.line 7
.line 8
goto L_3
.line 9
L_5:
return
.end method
