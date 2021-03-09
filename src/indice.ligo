#include "indice_types.ligo"

function increment(const param : int; const s : indiceStorage) : indiceFullReturn is 
block { skip } with ((nil: list(operation)), s + param)

function decrement(const param : int; const s : indiceStorage) : indiceFullReturn is 
block { skip } with ((nil: list(operation)), s - param)

function sendValue(const param : unit; const s : indiceStorage) : indiceFullReturn is 
block { 
    const c_opt : option(contract(int)) = Tezos.get_entrypoint_opt("%receiveValue", Tezos.sender);
    const destinataire : contract(int) = case c_opt of
    | Some(c) -> c
    | None -> (failwith("sender cannot receive indice value") : contract(int))
    end;
    const op : operation = Tezos.transaction(s, 0mutez, destinataire);
    const txs : list(operation) = list [ op; ];
 } with (txs, s)

function indiceMain(const ep : indiceEntrypoints; const store : indiceStorage) : indiceFullReturn is
block { 
    const ret : indiceFullReturn = case ep of 
    | Increment(p) -> increment(p, store)
    | Decrement(p) -> decrement(p, store)
    | SendValue(p) -> sendValue(p, store)
    end;
    
 } with ret

// ligo compile-contract indice.ligo indiceMain

//ligo dry-run indice.ligo indiceMain 'Increment(5)' '4'
//ligo dry-run indice.ligo indiceMain 'SendValue(unit)' '4'

//ligo compile-parameter indice.ligo indiceMain 'SendValue(unit)'
//ligo compile-storage indice.ligo indiceMain '4'

// tezos-client originate contract indice transferring 1 from bootstrap1  running '/home/frank/dev/esgi_project_2/indice.tz' --init '0' --dry-run