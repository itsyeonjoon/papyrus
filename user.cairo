%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin

@storage_var
func username() -> (res : felt): 
end

@storage_var 
func bio() -> (res : felt): 
end



@constructor 
func constructor{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr,
}(new_username : felt, new_bio : felt):
    username.write(new_username)
    bio.write(new_bio)
    return ()
end

