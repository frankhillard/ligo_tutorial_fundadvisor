#include "advisor_types.ligo"

function request(const p : unit; const s : advisorStorage) : advisorFullReturn is
block { 
    const c_opt : option(contract(unit)) = Tezos.get_entrypoint_opt("%sendValue", s.indiceAddress);
    const destinataire : contract(unit) = case c_opt of
    | Some(c) -> c
    | None -> (failwith("indice cannot send its value") : contract(unit))
    end;
    const op : operation = Tezos.transaction(unit, 0mutez, destinataire);
    const txs : list(operation) = list [ op; ];
 } with (txs, s)

function execute(const indiceVal : int; const s : advisorStorage) : advisorFullReturn is
block { 
    s.result := s.algorithm(indiceVal)
 } with ((nil : list(operation)), s)


function change(const p : advisorAlgo; const s : advisorStorage) : advisorFullReturn is
block { 
    s.algorithm := p;
 } with ((nil : list(operation)), s)

function advisorMain(const ep : advisorEntrypoints; const store : advisorStorage) : advisorFullReturn is
block { 
    const ret : advisorFullReturn = case ep of 
    | ReceiveValue(p) -> execute(p, store)
    | RequestValue(p) -> request(p, store)
    | ChangeAlgorithm(p) -> change(p, store)
    end;
 } with ret




 // ligo compile-contract advisor.ligo advisorMain

//ligo dry-run advisor.ligo advisorMain 'ReceiveValue(5)' 'record[indiceAddress=("KT1D99kSAsGuLNmT1CAZWx51vgvJpzSQuoZn" : address); algorithm=(False); result=False]'
//ligo dry-run advisor.ligo advisorMain 'RequestValue(unit)' 'record[indiceAddress=("KT1D99kSAsGuLNmT1CAZWx51vgvJpzSQuoZn" : address); algorithm=(False); result=False]'
//ligo dry-run advisor.ligo advisorMain 'ChangeAlgorithm(function(const i : int) is False)' 'record[indiceAddress=("KT1D99kSAsGuLNmT1CAZWx51vgvJpzSQuoZn" : address); algorithm=(False); result=False]'

//ligo compile-parameter advisor.ligo advisorMain 'ReceiveValue(5)'
//ligo compile-parameter advisor.ligo advisorMain 'RequestValue(unit)'
//ligo compile-parameter advisor.ligo advisorMain 'ChangeAlgorithm(function(const i : int) is False)'
//ligo compile-storage advisor.ligo advisorMain 'record[indiceAddress=("KT1D99kSAsGuLNmT1CAZWx51vgvJpzSQuoZn" : address); algorithm=(function(const i : int) is if i < 10 then True else False); result=False]'

// (Pair (Pair { PUSH int 10 ;
//               SWAP ;
//               COMPARE ;
//               LT ;
//               IF { PUSH bool True } { PUSH bool False } }
//             "KT1D99kSAsGuLNmT1CAZWx51vgvJpzSQuoZn")
//       False)

//(Pair (Pair { PUSH int 10 ; SWAP ;COMPARE ;LT ;IF { PUSH bool True } { PUSH bool False } } "KT1D99kSAsGuLNmT1CAZWx51vgvJpzSQuoZn") False)

// tezos-client originate contract advisor transferring 1 from bootstrap1  running '/home/frank/dev/esgi_project_2/advisor.tz' --init '(Pair (Pair { PUSH int 10 ; SWAP ;COMPARE ;LT ;IF { PUSH bool True } { PUSH bool False } } "KT1D99kSAsGuLNmT1CAZWx51vgvJpzSQuoZn") False)' --dry-run

// tezos-client transfer 0 from bootstrap3 to advisor --arg '(Right Unit)' --dry-run