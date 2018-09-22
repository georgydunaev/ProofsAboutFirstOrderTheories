(* PUBLIC DOMAIN *)
(* Author: Georgy Dunaev, georgedunaev@gmail.com *)
Require Export Coq.Vectors.Vector.
Require Export Coq.Lists.List.
Require Import Bool.Bool. 
(*Require Import Logic.FunctionalExtensionality.*)
(*Require Import Coq.Program.Wf.*)
(*Require Import Lia.*)
Add LoadPath "/home/user/0my/GITHUB/VerifiedMathFoundations/library".
Require Export UNIV_INST.
Require Export eqb_nat.
Require Export Terms.
Require Export Formulas.
Require Export Provability.

(*Require Import Logic.ClassicalFacts.*)
(*Axiom EquivThenEqual: prop_extensionality.*)

Module ModProp.
Definition Omega := Prop.
Definition OFalse := False.
Definition OAnd := and.
Definition OOr := or.
Definition OImp := (fun x y:Omega => x->y).
Notation Osig := ex.
End ModProp.

Module ModType.
Notation Omega := Type.
Definition OFalse := False. (*Print "+"%type.*)
Definition OAnd := prod.
Definition OOr := sum.
Definition OImp := (fun x y:Omega => x->y).
Notation Osig := sigT.
End ModType.


Module ModBool.
Definition Omega := bool.
Definition OFalse := false.
Definition OAnd := andb.
Definition OOr := orb.
Definition OImp := implb.
End ModBool.

Require Import Coq.Structures.Equalities.
(*Type*)
Module VS (SetVars FuncSymb PredSymb: UsualDecidableTypeFull) (*X: terms_mod SetVars*).
(*Module X := terms_mod SetVars FuncSymb.
Import X.*)
(*Module X := Formulas_mod SetVars FuncSymb PredSymb.
Export X.*)
Module X := Provability_mod SetVars FuncSymb PredSymb.
Export X.


Module Facts := BoolEqualityFacts SetVars.
Notation SetVars := SetVars.t.
Notation PredSymb := PredSymb.t.
Notation FuncSymb := FuncSymb.t.
(*Check SetVars.eqb.
Check SetVars.eq_refl.
Fail Check SetVars.eqb_refl.
Check Facts.eqb_refl.
Check eqb_refl. *)

Open Scope list_scope.


(* Here we choose an interpretation. *)
(*Export ModBool.*)
Export ModProp. (* + classical axioms *)
(*Export ModType. It doesn't work properly. *)
(** Soundness theorem section **)
Section cor.
 (* Truth values*)
Context (X:Type).
Check FSV.
(*Context (val:SetVars->X).*)
Context (fsI:forall(q:FSV),(Vector.t X (fsv q))->X).
Context (prI:forall(q:PSV),(Vector.t X (psv q))->Omega).
(*Context (prI:forall(q:PSV),(Vector.t X (psv q))->Prop).*)

Fixpoint teI (val:SetVars->X) (t:Terms): X.
Proof.
destruct t as [s|f t].
exact (val s).
refine (fsI f _).
simple refine (@Vector.map _ _ _ _ _).
2 : apply teI.
exact val.
exact t.
Defined.
(*
Fixpoint foI (val:SetVars->X) (f:Fo): Omega.
Proof.
destruct f.
+ refine (prI p _).
  apply (Vector.map  (teI val)).
  exact t.
+ exact false.
+ exact ( andb (foI val f1) (foI val f2)).
+ exact (  orb (foI val f1) (foI val f2)).
+ exact (implb (foI val f1) (foI val f2)).
+  (*Infinite conjunction!!!*)
 Show Proof.
*)

(** (\pi + (\xi \mapsto ?) ) **)
Definition cng (val:SetVars -> X) (xi:SetVars) (m:X) :=
(fun r:SetVars =>
match SetVars.eqb r xi with
| true => m
| false => (val r)
end).

(*Inductive foI (val:SetVars->X) (f:Fo): Prop
:=
   | cAtom p t0 => ?Goal0@{t:=t0}
.
   | cBot => ?Goal
   | cConj f1 f2 => ?Goal1
   | cDisj f1 f2 => ?Goal2
   | cImpl f1 f2 => ?Goal3
   | cFora x f0 => ?Goal4@{f:=f0}
   | cExis x f0 => ?Goal5@{f:=f0}
.*)

Fixpoint foI (val:SetVars->X) (f:Fo): Omega.
Proof.
destruct f.
Show Proof.
+ refine (prI p _).
  apply (@Vector.map Terms X (teI val)).
  exact t.
+ exact OFalse.
+ exact ( OAnd (foI val f1) (foI val f2)).
+ exact (  OOr (foI val f1) (foI val f2)).
+ exact ( OImp (foI val f1) (foI val f2)).
Show Proof.
+ exact (forall m:X, foI (cng val x m) f).
(*forall m:X, foI (fun r:SetVars =>
match Nat.eqb r x with
| true => m
| false => (val r)
end
) f*)
(*Locate "exists".*)
+ exact (Osig (fun m:X => foI (fun r:SetVars =>
match SetVars.eqb r x with
| true => m
| false => (val r)
end
) f)
).
(*+ exact (exists m:X, foI (fun r:SetVars =>
match PeanoNat.Nat.eqb r x with
| true => m
| false => (val r)
end
) f
).*)
Defined.

Definition ap {A B}{a0 a1:A} (f:A->B) (h:a0=a1):((f a0)=(f a1))
:= match h in (_ = y) return (f a0 = f y) with
   | eq_refl => eq_refl
   end.


Section Lem1.
(*Context (t : Terms).*)

(* page 136 of the book *)
Definition lem1 (t : Terms) : forall (u :Terms) (xi : SetVars) (pi : SetVars->X) ,
(teI pi (substT t xi u))=(teI (cng pi xi (teI pi t)) u).
Proof.
fix lem1 1.
intros.
induction u as [s|f].
(*destruct u as [s|f] .*)
+ simpl.
  unfold cng.
  destruct (SetVars.eqb s xi) eqn:ek. (* fsI as [H1|H2].*)
  * reflexivity.
  * simpl.
    reflexivity.
Show Proof.
+
  simpl. (* fsI teI *)
  destruct f.
  simpl.
  apply ap.
 simpl in * |- *.
apply (*Check *)
(proj1 (
eq_nth_iff X fsv0
(Vector.map (teI pi) (Vector.map (substT t xi) v))
(Vector.map (teI (cng pi xi (teI pi t))) v)
)).
intros.
(*rewrite H0.*)
 simpl in * |- *.
(* now I need to show that .nth and .map commute *)
Check nth_map (teI pi) (Vector.map (substT t xi) v) p1 p2 H0.
rewrite -> (nth_map (teI pi) (Vector.map (substT t xi) v) p1 p2 H0).
Check nth_map (teI (cng pi xi (teI pi t))) v.
rewrite -> (nth_map (teI (cng pi xi (teI pi t))) v p2 p2 ).
Check nth_map (substT t xi) v p2 p2 eq_refl.
rewrite -> (nth_map (substT t xi) v p2 p2 eq_refl).
exact (H p2).
reflexivity.
Defined.

End Lem1.

Theorem SomeInj {foo} :forall (a b : foo), Some a = Some b -> a = b.
Proof.
  intros a b H.
  inversion H.
  reflexivity.
Defined.

Theorem eq_equ (A B:Prop) : A=B -> (A <-> B).
Proof.
intro p. 
destruct p.
firstorder.
Defined. (* rewrite p. firstorder. *)

Theorem conj_eq (A0 B0 A1 B1:Prop)(pA:A0=A1)(pB:B0=B1): (A0 /\ B0) = (A1 /\ B1).
Proof. destruct pA, pB; reflexivity. Defined.
Theorem disj_eq (A0 B0 A1 B1:Prop)(pA:A0=A1)(pB:B0=B1): (A0 \/ B0) = (A1 \/ B1).
Proof. destruct pA, pB; reflexivity. Defined.
Theorem impl_eq (A0 B0 A1 B1:Prop)(pA:A0=A1)(pB:B0=B1): (A0 -> B0) = (A1 -> B1).
Proof. destruct pA, pB; reflexivity. Defined.
Lemma dbl_cng pi xi m1 m2: forall q,(cng (cng pi xi m1) xi m2) q = (cng pi xi m2) q.
Proof. intro q. unfold cng. destruct (SetVars.eqb q xi); reflexivity. Defined.


Theorem l01 h n v :
Vector.fold_left orb false (Vector.cons bool h n v) = Vector.fold_left orb (orb false h) v.
Proof.
simpl. reflexivity.
Defined.

Check all_then_someV.

Lemma all_then_someP (A:Type)(n:nat)(p:Fin.t (n)) (v:Vector.t A (n)) (P:A->bool)
(H : Vector.fold_left orb false (Vector.map P v) = false)
 : (P (Vector.nth v p)) = false.
Proof.
Check nth_map P v p p eq_refl.
rewrite <- (nth_map P v p p eq_refl).
apply all_then_someV. trivial.
Defined.

(* Not a parameter then not changed afted substitution (for Terms) *)
Lemma NPthenNCAST (u:Terms)(xi:SetVars)(t:Terms) (H:(isParamT xi u=false))
: (substT t xi u) = u.
Proof. induction u.
+ simpl in * |- *.
  rewrite H. reflexivity.
+ simpl in * |- *.
  apply ap.
apply eq_nth_iff.
intros p1 p2 ppe.
Check nth_map _ _ _ p2 ppe.
rewrite (nth_map _ _ _ p2 ppe).
apply H0.
simpl.
apply all_then_someP.
trivial.
Defined.

Lemma NPthenNCAST_vec:forall p xi t ts (H:(isParamF xi (Atom p ts)=false)), 
  (Vector.map (substT t xi) ts) = ts.
Proof.
  intros p xi t1 ts H.
  apply eq_nth_iff.
  intros p1 p2 H0.
  Check nth_map (substT t1 xi) ts p1 p2 H0.
  rewrite -> (nth_map (substT t1 xi) ts p1 p2 H0).
  apply NPthenNCAST.
  apply all_then_someP.
  simpl in H.
  exact H.
Defined.


(* Not a parameter then not changed afted substitution (for Formulas) *)
Fixpoint NPthenNCASF (mu:Fo) : forall (xi:SetVars)(t:Terms) (H:(isParamF xi mu=false))
   , substF t xi mu = Some mu .
Proof. (*induction mu eqn:u0.*)
destruct mu eqn:u0.
Check t.
* intros xi t0 H.
  simpl.
  rewrite -> NPthenNCAST_vec; (trivial || assumption).
* intros xi t H.
  simpl; trivial.
* intros xi t H.
  simpl.
  simpl in H.
  (*pose (Q:=A1 _ _ H).*)
  destruct (A1 _ _ H) as [H0 H1].
  rewrite -> NPthenNCASF .
  rewrite -> NPthenNCASF .
  (*rewrite -> IHf1 with xi t.
  rewrite -> IHf2 with xi t.*)
  trivial.
  trivial.
  trivial.
* simpl.
  intros xi t H.
  destruct (A1 _ _ H) as [H0 H1].
  rewrite -> NPthenNCASF .
  rewrite -> NPthenNCASF .
  (*rewrite -> IHmu1 with xi t.
  rewrite -> IHmu2 with xi t.*)
  trivial.
  trivial.
  trivial.
* simpl.
  intros xi t H.
  destruct (A1 _ _ H) as [H0 H1].
  rewrite -> NPthenNCASF .
  rewrite -> NPthenNCASF .
  trivial.
  trivial.
  trivial.
* simpl.
  intros xi t H.
  destruct (SetVars.eqb x xi) eqn:u2.
  trivial.
  destruct (isParamF xi f) eqn:u1.
  inversion H.
  trivial.
* simpl.
  intros xi t H.
  destruct (SetVars.eqb x xi) eqn:u2.
  trivial.
  destruct (isParamF xi f) eqn:u1.
  inversion H.
  trivial.
Defined.

(* p.137 *)
Section Lem2.

Lemma mqd x t pi m (H:isParamT x t = false): (teI (cng pi x m) t) = (teI pi t).
Proof.
induction t.
 simpl.
simpl in H.
unfold cng.
rewrite -> H.
reflexivity.
 simpl.
simpl in H.
apply ap.
apply eq_nth_iff.
intros.
Check nth_map (teI (cng pi x m)) v p1 p1 eq_refl.
rewrite -> (nth_map (teI (cng pi x m)) v p1 p1 eq_refl).
rewrite -> (nth_map (teI pi) v p2 p2 eq_refl).
rewrite <- H1.
apply H0.
exact (all_then_someP _ _ p1 _ (isParamT x) H).
Defined.

Lemma IOF xi : SetVars.eqb xi xi = true.
Proof.
exact (Facts.eqb_refl xi).
Defined.

(* USELESS THEOREM *)
Lemma cng_commT  x xi m0 m1 pi t :
SetVars.eqb x xi = false -> 
teI (cng (cng pi x m0) xi m1) t = teI (cng (cng pi xi m1) x m0) t.
Proof. intro i.
revert pi.
induction t; intro pi.
simpl.
unfold cng.
(*destruct (Nat.eqb x xi) eqn:j.
inversion i. NO*)
Check not_iff_compat (SetVars.eqb_eq x xi).
pose (n3:= proj1 (not_iff_compat (SetVars.eqb_eq x xi)) ).
Check proj2 (not_true_iff_false (SetVars.eqb x xi)).
pose (n4:= n3 (proj2 (not_true_iff_false (SetVars.eqb x xi)) i)).
Require Import Arith.Peano_dec.
Check eq_nat_dec.
destruct (SetVars.eq_dec sv xi).
rewrite -> e.
rewrite -> IOF.
destruct (SetVars.eq_dec x xi).
destruct (n4 e0).
pose (hi := (not_eq_sym n)).

Check not_true_iff_false .
pose (ih:= not_true_is_false _ (proj2 (not_iff_compat (SetVars.eqb_eq xi x)) hi)).
rewrite ih.
reflexivity.
pose (ih:= not_true_is_false _ (proj2 (not_iff_compat (SetVars.eqb_eq sv xi)) n)).
rewrite -> ih.
reflexivity.
simpl.
apply ap.
apply eq_nth_iff.
intros p1 p2 HU.

Check nth_map (teI (cng (cng pi x m0) xi m1)) v p1 p2 HU.
rewrite -> (nth_map (teI (cng (cng pi x m0) xi m1)) v p1 p2 HU).
Check nth_map.
rewrite -> (nth_map (teI (cng (cng pi xi m1) x m0)) v p2 p2 eq_refl).
apply H.
Defined.

Lemma EqualThenEquiv A B: A=B -> (A<->B). intro H. rewrite H. exact (iff_refl B). Defined.

Lemma ix W (P Q:W->Prop) (H: P = Q):(forall x, P x) =(forall y, Q y).
Proof.
rewrite H.
reflexivity.
Defined.

Lemma weafunT pi mu (q: forall z, pi z = mu z) t : teI pi t = teI mu t.
Proof.
induction t.
+ simpl. exact (q sv).
+ simpl. apply ap.
  apply eq_nth_iff.
  intros p1 p2 HU.
  rewrite -> (nth_map (teI pi) v p1 p2 HU).
  rewrite -> (nth_map (teI mu) v p2 p2 eq_refl).
  apply H.
Defined.
Print Omega.
Locate "<->". (* iff *)
Lemma weafunF pi mu (q: forall z, pi z = mu z) fi : foI pi fi <-> foI mu fi.
Proof.
revert pi mu q.
induction fi.
intros pi mu q.
+ simpl.
  apply EqualThenEquiv.
  apply ap.
  apply eq_nth_iff.
  intros p1 p2 HU.
  rewrite -> (nth_map (teI pi) t p1 p2 HU).
  rewrite -> (nth_map (teI mu) t p2 p2 eq_refl).
  apply weafunT.
  apply q.
+ simpl. reflexivity.
+ simpl. intros. 
  rewrite -> (IHfi1 pi mu q) (*weafunF pi mu q fi1*).
  rewrite -> (IHfi2 pi mu q) (*weafunF pi mu q fi2*).
  reflexivity.
+ simpl. intros. 
  rewrite -> (IHfi1 pi mu q) (*weafunF pi mu q fi1*).
  rewrite -> (IHfi2 pi mu q) (*weafunF pi mu q fi2*).
  reflexivity.
+ simpl.
  unfold OImp.
  split;
  intros;
  apply (IHfi2 pi mu q (*pi m0 m1 xe xi i*));
  apply H;
  apply (IHfi1 pi mu q (*pi m0 m1 xe xi i*));
  apply H0. (*twice*)
+ simpl.
  split.
  * intros.
    rewrite IHfi. (*weafunF.*)
    apply H.
    intro z.
    unfold cng.
    destruct (SetVars.eqb z x).
    reflexivity.
    symmetry.
    apply q.
  * intros.
    rewrite IHfi.
    apply H.
    intro z.
    unfold cng.
    destruct (SetVars.eqb z x).
    reflexivity.
    apply q.
+ simpl.
  split.
  * intros.
destruct H as [m H].
exists m.
    rewrite IHfi. (*weafunF.*)
    apply H.
    intro z.
    unfold cng.
    destruct (SetVars.eqb z x).
    reflexivity.
    symmetry.
    apply q.
  * intros.
destruct H as [m H].
exists m.
    rewrite IHfi.
    apply H.
    intro z.
    unfold cng.
    destruct (SetVars.eqb z x).
    reflexivity.
    apply q.
Defined.

Lemma cng_commF_EQV  xe xi m0 m1 pi fi :
SetVars.eqb xe xi = false -> 
(foI (cng (cng pi xe m0) xi m1) fi <-> foI (cng (cng pi xi m1) xe m0) fi).
Proof.
intros H.
apply weafunF.
intros z.
unfold cng.
destruct (SetVars.eqb z xi) eqn:e0, (SetVars.eqb z xe) eqn:e1.
pose (U0:= proj1 (SetVars.eqb_eq z xi) e0).
rewrite U0 in e1.
pose (U1:= proj1 (SetVars.eqb_eq xi xe) e1).
symmetry in U1.
pose (U2:= proj2 (SetVars.eqb_eq xe xi) U1).
rewrite U2 in H.
inversion H.
reflexivity. reflexivity. reflexivity.
Defined.

Lemma AND_EQV : forall A0 B0 A1 B1 : Prop, 
(A0 <-> A1) -> (B0 <-> B1) -> ((A0 /\ B0) <-> (A1 /\ B1)).
Proof.
intros A0 B0 A1 B1 H0 H1.
rewrite H0.
rewrite H1.
reflexivity.
Defined.
Lemma OR_EQV : forall A0 B0 A1 B1 : Prop, 
(A0 <-> A1) -> (B0 <-> B1) -> ((A0 \/ B0) <-> (A1 \/ B1)).
Proof.
intros A0 B0 A1 B1 H0 H1.
rewrite H0.
rewrite H1.
reflexivity.
Defined.
Lemma IMP_EQV : forall A0 B0 A1 B1 : Prop, 
(A0 <-> A1) -> (B0 <-> B1) -> ((A0 -> B0) <-> (A1 -> B1)).
Proof.
intros A0 B0 A1 B1 H0 H1.
rewrite H0.
rewrite H1.
reflexivity.
Defined.
Lemma FORALL_EQV : forall A0 A1 : X -> Prop, 
(forall m, A0 m <-> A1 m) -> ((forall m:X, A0 m) <-> (forall m:X, A1 m)).
Proof.
intros A0 A1 H0.
split.
+ intros.
  rewrite <- H0.
  exact (H m).
+ intros.
  rewrite -> H0.
  exact (H m).
Defined.


Lemma lem2caseAtom : forall (p : PSV) (t0 : Vector.t Terms (psv p))
(t : Terms) (xi : SetVars) (pi : SetVars->X)
(r:Fo) (H:(substF t xi (Atom p t0)) = Some r) ,
foI pi r <-> foI (cng pi xi (teI pi t)) (Atom p t0).
Proof.
intros.
+  (*simpl in *|-*; intros r H.*)
  pose (Q:=SomeInj _ _ H).
  rewrite <- Q.
  simpl.
apply EqualThenEquiv.
  (*apply eq_equ.*)
  apply ap.
  apply 
    (proj1 (
      eq_nth_iff X (psv p) 
      (Vector.map (teI pi) (Vector.map (substT t xi) t0))
      (Vector.map (teI (cng pi xi (teI pi t))) t0)
    )).
  rename t0 into v.
  intros p1 p2 H0.
  rewrite -> (nth_map (teI pi) (Vector.map (substT t xi) v) p1 p2 H0).
  rewrite -> (nth_map (teI (cng pi xi (teI pi t))) v p2 p2 ).
  rewrite -> (nth_map (substT t xi) v p2 p2 eq_refl).
  apply lem1. reflexivity.
Defined.

Lemma twice_the_same pi x m0 m1 : 
forall u, (cng (cng pi x m0) x m1) u = (cng pi x m1) u.
Proof.
intro u.
unfold cng.
destruct (SetVars.eqb u x).
reflexivity.
reflexivity.
Defined.

(*Lemma eqb_comm x xi : PeanoNat.Nat.eqb xi x =  PeanoNat.Nat.eqb x xi.
unfold PeanoNat.Nat.eqb.
Admitted.*)

Lemma NPthenNCACVT x t m pi: 
 isParamT x t = false -> (teI (cng pi x m) t) = (teI pi t).
Proof.
intros H.
induction t.
unfold cng.
simpl in * |- *.
rewrite H.
reflexivity.
simpl in * |- *.
apply ap.
apply eq_nth_iff.
intros.
Check nth_map .
Check nth_map (teI (cng pi x m)) v p1 p2 H1.
rewrite -> (nth_map (teI (cng pi x m)) v p1 p2 H1).
Check nth_map (teI pi) v p1 p2 H1.
rewrite -> (nth_map (teI pi) v p2 p2 eq_refl).
apply H0.
Check all_then_someP.

Check all_then_someP Terms (fsv f) p2 v (isParamT x) H.
apply (all_then_someP Terms (fsv f) p2 v (isParamT x) H).
Defined.

Lemma orb_elim (a b:bool): ((a||b)=false)->((a=false)/\(b=false)).
Proof.
intros. destruct a,b. 
simpl in H. inversion H.
simpl in H. inversion H.
firstorder.
firstorder.
Defined.

Lemma EXISTS_EQV : forall A0 A1 : X -> Prop, 
(forall m, A0 m <-> A1 m) -> ((exists m:X, A0 m) <-> (exists m:X, A1 m)).
Proof.
intros A0 A1 H0.
split.
+ intros.
  destruct H as [x Hx].
  exists x.
  rewrite <- H0.
  exact (Hx).
+ intros.
  destruct H as [x Hx].
  exists x.
  rewrite -> H0.
  exact (Hx).
Defined.

Lemma NPthenNCACVF xi fi m mu :  isParamF xi fi = false ->
foI (cng mu xi m) fi <-> foI mu fi.
Proof.
revert mu.
induction fi; intro mu;
intro H;
simpl in * |- *.
* apply EqualThenEquiv.
  apply ap.
  apply eq_nth_iff.
  intros p1 p2 H0.
  Check eq_nth_iff.
  Check nth_map (teI (cng mu xi m)) t p1 p2 H0.
  rewrite -> (nth_map (teI (cng mu xi m)) t p1 p2 H0).
  Check nth_map (teI mu) t p2 p2 eq_refl.
  rewrite -> (nth_map (teI mu) t p2 p2 eq_refl).
  Check NPthenNCACVT. 
  apply NPthenNCACVT.
  Check all_then_someP Terms (psv p) p2 t (isParamT xi) H.
  apply (all_then_someP Terms (psv p) p2 t (isParamT xi) H).
  (*1st done *)
* firstorder.
* apply AND_EQV.
  apply IHfi1. destruct (orb_elim _ _ H). apply H0.
  apply IHfi2. destruct (orb_elim _ _ H). apply H1.
* apply OR_EQV.
  apply IHfi1. destruct (orb_elim _ _ H). apply H0.
  apply IHfi2. destruct (orb_elim _ _ H). apply H1.
* apply IMP_EQV.
  apply IHfi1. destruct (orb_elim _ _ H). apply H0.
  apply IHfi2. destruct (orb_elim _ _ H). apply H1.
* apply FORALL_EQV. intro m0.
  destruct (SetVars.eqb x xi) eqn:e1.
  pose (C:=proj1 (SetVars.eqb_eq x xi) e1).
  rewrite <- C.
  pose (D:= twice_the_same mu x m m0).
  exact (weafunF _ _ D fi).
Check cng_commF_EQV x xi m0 m.
  rewrite cng_commF_EQV.
(* here inductive IHfi*)
apply IHfi.
exact H.

Lemma eqb_comm x xi : SetVars.eqb xi x =  SetVars.eqb x xi.
Proof.
destruct (SetVars.eqb xi x) eqn:e1.
symmetry.
pose (Y:= proj1 (SetVars.eqb_eq xi x) e1).
rewrite -> Y at 1.
rewrite <- Y at 1.
exact e1.
symmetry.
pose (n3:= proj2 (not_iff_compat (SetVars.eqb_eq x xi)) ).
apply not_true_iff_false.
apply n3.
intro q.
symmetry in q.
revert q.
fold (xi <> x).
pose (n5:= proj1 (not_iff_compat (SetVars.eqb_eq xi x)) ).
apply n5.
apply not_true_iff_false.
exact e1.
Defined.

rewrite <-(eqb_comm xi x).
exact e1.
* 

apply EXISTS_EQV. intro m0.
fold (cng (cng mu xi m) x m0).
fold (cng mu x m0). (* Print cng. Check cng mu xi m. *)

  destruct (SetVars.eqb x xi) eqn:e1.
  pose (C:=proj1 (SetVars.eqb_eq x xi) e1).
  rewrite <- C.
  pose (D:= twice_the_same mu x m m0).
  exact (weafunF _ _ D fi).
Check cng_commF_EQV x xi m0 m.
  rewrite cng_commF_EQV.
(* here inductive IHfi*)
apply IHfi.
exact H.
rewrite <-(eqb_comm xi x).
exact e1.
Defined.

Definition lem2 (t : Terms) : forall (fi : Fo) (xi : SetVars) (pi : SetVars->X)
(r:Fo) (H:(substF t xi fi) = Some r), (*(SH:sig (fun(r:Fo)=>(substF t xi fi) = Some r)),*)
(foI pi r)<->(foI (cng pi xi (teI pi t)) fi).
Proof.
fix lem2 1.
(*H depends on t xi fi r *)
intros fi xi pi r H.
revert pi r H.
induction fi;
intros pi r H.
+ apply lem2caseAtom.
  exact H.
+  (*simpl in *|-*; intros r H.*)
   inversion H. simpl. reflexivity.
+  simpl in *|-*; (*intros r H.*)
  destruct (substF t xi fi1) as [f1|].
  destruct (substF t xi fi2) as [f2|].
  pose (Q:=SomeInj _ _ H).
  rewrite <- Q.
(* here! *)
Check conj_eq.
simpl.
unfold OAnd.
apply AND_EQV.
  simpl in * |- *.
  * apply (IHfi1 pi f1 eq_refl).
  * apply (IHfi2 pi f2 eq_refl).
  * inversion H.
  * inversion H.
+ simpl in *|-*. (*; intros r H.*)
  destruct (substF t xi fi1) as [f1|].
  destruct (substF t xi fi2) as [f2|].
  pose (Q:=SomeInj _ _ H).
  rewrite <- Q.
  simpl in * |- *.
apply OR_EQV.
  (*apply disj_eq ;   fold foI.*)
  * apply (IHfi1 pi f1 eq_refl).
  * apply (IHfi2 pi f2 eq_refl).
  * inversion H.
  * inversion H.
+ simpl in *|-*. (*; intros r H.*)
  destruct (substF t xi fi1) as [f1|].
  destruct (substF t xi fi2) as [f2|].
  pose (Q:=SomeInj _ _ H).
  rewrite <- Q.
  simpl in * |- *.
  apply IMP_EQV. (*apply impl_eq ;   fold foI.*)
  * apply (IHfi1 pi f1 eq_refl).
  * apply (IHfi2 pi f2 eq_refl).
  * inversion H.
  * inversion H.
+
simpl in * |- *.

destruct (SetVars.eqb x xi) eqn:l2.
pose (Q:=SomeInj _ _ H).
rewrite <- Q.
simpl.
apply FORALL_EQV.
intro m.
assert (RA : x = xi).
apply (SetVars.eqb_eq x xi ).
exact l2.
rewrite <- RA.
Check weafunF (cng (cng pi x (teI pi t)) x m) (cng pi x m) 
(twice_the_same pi x (teI pi t) m) fi.
rewrite -> (weafunF (cng (cng pi x (teI pi t)) x m) (cng pi x m) 
(twice_the_same pi x (teI pi t) m) fi).
firstorder.

destruct (isParamF xi fi) eqn:l1.
pose(xint := (isParamT x t)).
destruct (isParamT x t) eqn:l3.
inversion H.
destruct (substF t xi fi) eqn:l4.
 pose (Q:=SomeInj _ _ H).
rewrite <- Q.
simpl.
apply FORALL_EQV.
intro m.
Check cng_commF_EQV.
rewrite cng_commF_EQV.
2 : {
rewrite -> eqb_comm .
exact l2. }

Check IHfi (cng pi x m) f eq_refl.

Check IHfi (cng pi x m) f eq_refl.
Check NPthenNCACVT x t m pi l3.
rewrite <- (NPthenNCACVT x t m pi l3).
Check IHfi (cng pi x m) f eq_refl.
exact (IHfi (cng pi x m) f eq_refl).
inversion H.
 pose (Q:=SomeInj _ _ H).
rewrite <- Q.
simpl.
apply FORALL_EQV.
intro m.
Check cng_commF_EQV.
Check IHfi (cng pi x m) fi.

rewrite cng_commF_EQV.
Check NPthenNCACVF.
symmetry.
exact (NPthenNCACVF xi fi (teI pi t) (cng pi x m) l1).
rewrite -> (eqb_comm x xi).
exact l2.
(* end of FORALL case*)
+
simpl in * |- *.

destruct (SetVars.eqb x xi) eqn:l2.
pose (Q:=SomeInj _ _ H).
rewrite <- Q.
simpl.
apply EXISTS_EQV.
intro m.
assert (RA : x = xi).
apply (SetVars.eqb_eq x xi ).
exact l2.
rewrite <- RA.
Check weafunF (cng (cng pi x (teI pi t)) x m) (cng pi x m) 
(twice_the_same pi x (teI pi t) m) fi.
rewrite -> (weafunF (cng (cng pi x (teI pi t)) x m) (cng pi x m) 
(twice_the_same pi x (teI pi t) m) fi).
firstorder.

destruct (isParamF xi fi) eqn:l1.
pose(xint := (isParamT x t)).
destruct (isParamT x t) eqn:l3.
inversion H.
destruct (substF t xi fi) eqn:l4.
 pose (Q:=SomeInj _ _ H).
rewrite <- Q.
simpl.
apply EXISTS_EQV.
intro m.
Check cng_commF_EQV.
fold (cng  pi x m ).
fold (cng  (cng pi xi (teI pi t)) x m ).

rewrite cng_commF_EQV.
2 : {
rewrite -> eqb_comm .
exact l2. }

Check IHfi (cng pi x m) f eq_refl.

Check IHfi (cng pi x m) f eq_refl.
Check NPthenNCACVT x t m pi l3.
rewrite <- (NPthenNCACVT x t m pi l3).
Check IHfi (cng pi x m) f eq_refl.
exact (IHfi (cng pi x m) f eq_refl).
inversion H.
 pose (Q:=SomeInj _ _ H).
rewrite <- Q.
simpl.
apply EXISTS_EQV.
intro m.
Check cng_commF_EQV.
Check IHfi (cng pi x m) fi.
fold (cng  pi x m ).
fold (cng  (cng pi xi (teI pi t)) x m ).

rewrite cng_commF_EQV.
Check NPthenNCACVF.
symmetry.
exact (NPthenNCACVF xi fi (teI pi t) (cng pi x m) l1).
rewrite -> (eqb_comm x xi).
exact l2.
Defined. (* END OF LEM2 *)
End Lem2.

Lemma UnivInst : forall (fi:Fo) (pi:SetVars->X) (x:SetVars) (t:Terms)
(r:Fo) (H:(substF t x fi)=Some r), foI pi (Impl (Fora x fi) r).
Proof.
intros fi pi x t r H.
simpl.
intro H0.
apply (lem2 t fi x pi r H).
apply H0.
Defined.

Lemma ExisGene : forall (fi:Fo) (pi:SetVars->X) (x:SetVars) (t:Terms)
(r:Fo) (H:(substF t x fi)=Some r), foI pi (Impl r (Exis x fi)).
Proof.
intros fi pi x t r H.
simpl.
intro H0.
exists (teI pi t).
fold (cng pi x (teI pi t)).
apply (lem2 t fi x pi r H).
apply H0.
Defined.
(* PROOF OF THE SOUNDNESS *)
Theorem correct (f:Fo) (l:list Fo) (m:PR l f) 
(lfi : forall  (h:Fo), (InL h l)-> forall (val:SetVars->X), (foI val h)) : 
forall (val:SetVars->X), foI val f.
Proof.
revert lfi.
induction m (* eqn: meq *); intros lfi val.
+ exact (lfi A i _).
+ destruct a.
  ++ simpl.
     intros a b.
     exact a.
  ++ simpl.
     intros a b c.
     exact (a c (b c)).
+ simpl in *|-*.
  destruct (substF t xi ph) eqn: j.
  apply (UnivInst ph val xi t f j).
  simpl. firstorder.
+ simpl in *|-*.
  unfold OImp.
  intros H0 H1 m.
  apply H0.
  rewrite -> (NPthenNCACVF xi ps0 m val H).
  exact H1.
+ simpl in * |- *.
  unfold OImp in IHm2.
apply IHm2.
apply lfi.
apply IHm1.
apply lfi. (*  exact (IHm2 IHm1).*)
+ simpl in * |- *.
  intro m0.
apply IHm.
intros h B.
intro val2.
apply lfi.
exact B.
Defined.
(** SOUNDNESS IS PROVED **)
End cor.
(*End sec0.*)
End VS.

