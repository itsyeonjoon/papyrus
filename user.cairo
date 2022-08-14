%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin

@contract_interface
namespace PostContract:
    func like_post():
    end

    func comment_post(content : felt):
    end
end

### --- list of @storage_var (field) functions --- ###

# owner of the user account by their wallet contract address
@storage_var 
func owner() -> (owner_address : felt): 
end 

# username of the account 
@storage_var
func username() -> (res : felt): 
end

# bio of the account 
@storage_var 
func bio() -> (res : felt): 
end

# list of posts of the account
@storage_var
func posts() -> (res : felt*): 
end

# number of posts of the account
@storage_var
func posts_count() -> (res : felt): 
end

@constructor 
func constructor{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr,
}(new_username : felt, new_bio : felt):
    let (caller_address) = get_caller_address()
    owner.write(caller_address)
    username.write(new_username)
    bio.write(new_bio)
    posts_count.write(0)
    return ()
end

@external 
func edit_bio{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr,
}(new_bio : felt):
    let (caller_address) = get_caller_address()
    assert caller_address == owner.read()
    bio.write(new_bio)
    return ()
end

@external 
func add_post{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr,
}(post_address : felt):
    let (caller_address) = get_caller_address()
    assert caller_address == owner.read()

    let (res) = posts.read()
    let (num) = posts_count.read()

    res[num] = post_address
    posts.write(res)
    posts_count.write(num + 1)
    return ()
end

@external
func call_like_post{syscall_ptr : felt*, range_check_ptr}(
    contract_address : felt
):
    PostContract.like_post(
        contract_address=contract_address
    )
    return ()
end

@external
func call_comment_post{syscall_ptr : felt*, range_check_ptr}(
    contract_address : felt, content : felt
):
    PostContract.comment_post(
        contract_address=contract_address, content=content
    )
    return ()
end

### --- list of @view (getter) functions --- ###

@view
func view_username{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr,
}() -> (res : felt):
    let (res) = username.read()
    return (res=res)
end

@view
func view_bio{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr,
}() -> (res : felt):
    let (res) = bio.read()
    return (res=res)
end

@view 
func view_posts{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr,
}() -> (res : felt*):
    let (res) = posts.read()
    return (res=res)
end

@view 
func view_posts_count{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr,
}() -> (res : felt):
    let (res) = posts_count.read()
    return (res=res)
end


