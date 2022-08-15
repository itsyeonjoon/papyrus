%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin

from starkware.starknet.common.syscalls import (
    get_contract_address,
)

# Comment struct contains two members: 
#      user - username 
#      content - actual comment 
struct Comment: 
    member user : felt
    member content : felt
end

# Brings user contract owned by a user who created the post. Will add post contract address
# to the user contract's posts @storage_var: 
@contract_interface
namespace UserContract:
    func add_post(post_address : felt):
    end
end

### --- list of @storage_var (field) functions --- ###

# owner of the post (owner address) 
@storage_var 
func owner() -> (owner_address : felt): 
end 

# description of the post 
@storage_var 
func description() -> (res : felt): 
end

# image associated to the post
@storage_var 
func image() -> (res : felt): 
end

# list of users who liked the post 
@storage_var 
func likes_list() -> (res : felt): 
end

# number of people who liked the post 
@storage_var 
func likes_count() -> (res : felt): 
end

# list of Comments in the post 
@storage_var 
func comments_list() -> (res : Comment*): 
end

# number of people who commented the post 
@storage_var 
func comments_count() -> (res : felt): 
end

### --- constructor for the post contract --- ###

# constructor initializes a post contract, setting the owner to be the one who 
# published the contract. Likes and comments counts are defaulted to 0. 
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

# calling this will allow caller to "like" the post. 
# adds their user address to the likes_list, and increases
# likes_count by 1. 
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

# calling this will allow caller to "comment" the post. 
# adds their Comment to the comment_list, and increases
# comments_count by 1. 
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

# edits the description of the post
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

# calls add_post of User Contract. See add_post function in user.cairo. 
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

# gets number of likes of the post. 
@view 
func view_likes_count{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr,
}() -> (res : felt):
    let (res) = likes_count.read()
    return (res=res)
end

# gets number of comments of the post.
@view
func view_comments_count{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr,
}() -> (res : felt):
    let (res) = comments_count.read()
    return (res=res)
end