# We use Marshall Lochbaum's csv parser from bqnlibs
# Edit the following line with the correct path:
bqnlibs ← "/home/omar/code/bqn-libs/"

csv ⇐ ⟨""";"∾@+10⟩ •Import bqnlibs •file.At "csv.bqn"

str ⇐ •Import bqnlibs •file.At "strings.bqn"

DL ⇐ {
 •file.CreateDir⎊@ "data"
 y ← •Fmt 𝕩
 ⊑•SH ⟨"wget", "-O", "data/scimagojr_"∾y∾".csv",
       "https://www.scimagojr.com/journalrank.php?year="∾y∾"&type=all&out=xls"⟩
}

AdHocFixes ⇐ ⟨⟨"jiu"" "⟩, ⟨"jiu"""" "⟩⟩⊸str.ReplaceAll

SJR ⇐ {csv.Split AdHocFixes ¯1↓•file.Chars "data/scimagojr "∾(•Fmt 𝕩)∾".csv"}

Years ⇐ {𝕊:∧(•ParseFloat 10↓¯4↓⊢)¨("scimagojr "≡10⊸↑)¨⊸/•file.List "data"}

MathJournals ⇐ {
 fields‿table ← (⊑ ⋈ ⍉∘>∘(1⊸↓)) SJR 𝕩
 [title, quartile, area] ← table⊏˜fields⊐⟨"Title", "Categories", "Areas"⟩
 math ← (∨´"Mathematics"⊸⍷)¨area
 math⊸/˘ [title, quartile]
}

WriteMathCSV ⇐ {𝕤
 mj ← MathJournals¨ y ← Years@
 all ← ∧ ∾´ y {[t,q]←𝕩 ⋄ ⍉[t,(≠t)⥊<•Fmt 𝕨,q]}¨ mj
 "data/mathsjr.csv" •file.Chars csv.Join all
}

EscapeQuotes ⇐ {e←≠`'"'=s←(1+'"'=𝕩)/𝕩⋄'\'¨⌾(e⊸/)s}
ElispString ⇐ '"'∾'"'∾˜EscapeQuotes

WriteMathElisp ⇐ {𝕤
 mj ← MathJournals¨ y ← Years@
 all ← ∧ ∾´ y {[t,q]←𝕩 ⋄ ⍉[t,(≠t)⥊<•Fmt 𝕨,q]}¨ mj
 lines ← ('('∾')'∾˜⊢)∘(1⊸↓∘∾' '⊸∾¨)∘(ElispString¨)¨ <˘ all
 "data/mathsjr.lisp" •file.Lines ⟨"("⟩∾lines∾⟨")"⟩
 }
