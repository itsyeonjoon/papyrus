%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin

from starkware.starknet.common.syscalls import (
    get_contract_address,
)

struct Comment: 
    member user : felt
    member content : felt
end

@contract_interface
namespace UserContract:
    func add_post(post_address : felt):
    end
end

### --- list of @storage_var (field) functions --- ###

@storage_var 
func owner() -> (owner_address : felt): 
end 

@storage_var 
func description() -> (res : felt): 
end

@storage_var 
func image() -> (res : felt): 
end

@storage_var 
func likes_list() -> (res : felt): 
end

@storage_var 
func likes_count() -> (res : felt): 
end

@storage_var 
func comments_list() -> (res : Comment*): 
end

@storage_var 
func comments_count() -> (res : felt): 
end

### --- constructor for the post contract --- ###

@constructor 
func constructor{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr,
}(initial_description : felt, initial_image : felt):
    let (owner_address) = get_caller_address()
    owner.write(value=owner_address)
    description.write(value=initial_description)
    image.write(value=initial_image)
    likes_count.write(0)
    comments_count.write(0)
    return ()
end

### --- list of @external (setter) functions --- ###

@external 
func like_post{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr,
}():
    let (user) = get_caller_address()
    likes_list + likes_count.read() = user
    likes_count.write(likes_count.read() + 1)
    return ()
end

@external 
func comment_post{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr,
}(content : felt):
    let (user) = get_caller_address()
    let (new_comment) = Comment(user=user, content=content)
    comments_list + Comment.SIZE * comments_count.read() = new_comment
    comments_count.write(comments_count.read() + 1)
    return ()
    # increase comment_count by 1
    # append a new comment struct to comments array 
end

@external 
func edit_description{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr,
}(new_desc : felt):
    let (caller_address) = get_caller_address()
    assert caller_address == owner.read()
    description.write(new_desc)
end

@external
func call_add_post{syscall_ptr : felt*, range_check_ptr}(
    user_contract_address : felt
):
    UserContract.like_post(
        contract_address=user_contract_address, post_address=get_contract_address()
    )
    return ()
end

### --- list of @view (getter) functions --- ###

@view 
func view_likes_count{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr,
}() -> (res : felt):
    let (res) = likes_count.read()
    return (res=res)
end


@view
func view_comments_count{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr,
}() -> (res : felt):
    let (res) = comments_count.read()
    return (res=res)
end