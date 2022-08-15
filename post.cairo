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

# stores users who liked the post. We use map here 
# for easier implementation than array
#     parameter (idx : felt) acts as an index in arrays in other programming languages
#     returns (res : felt) that returns associated user who liked the post. 
@storage_var 
func likes_list(idx : felt) -> (res : felt): 
end

# number of people who liked the post 
@storage_var 
func likes_count() -> (res : felt): 
end

# stores users who commented the post. We use map here 
# for easier implementation than array
#     parameter (idx : felt) acts as an index in arrays in other programming languages
#     returns associated (res : Comment) that returns the Comment struct. 
@storage_var 
func comments_list(idx : felt) -> (res : Comment): 
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
# likes_count by 1. It is not designed to be called by directly, 
# but is intended to be called within user.cairo. 
@external 
func like_post{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr,
}(username : felt):
    validate_like_post(idx=0)

    let (next_idx) = likes_count.read()
    likes_list.write(next_idx, username)
    likes_count.write(next_idx + 1)
    return ()
end

func validate_like_post{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr,
}(username : felt, idx : felt): 
    if idx == likes_count.read():
        return ()
    assert likes_list.read(idx) != username
    validate_like_post(username=username, idx=idx+1)

# calling this will allow caller to "comment" the post. 
# adds their Comment to the comment_list, and increases
# comments_count by 1. It is not designed to be called by directly, 
# but is intended to be called within user.cairo. 
@external 
func comment_post{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr,
}(content : felt, username : felt):
    validate_comment_post(username=username, idx=0)
    
    let (next_idx) = comments_count.read()
    let (new_comment) = Comment(user=username, content=content)
    comments_list.write(next_idx, new_comment)
    comments_count.write(next_idx + 1)
    return ()
end

func validate_comment_post{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr,
}(username : felt, idx : felt): 
    if idx == comments_count.read():
        return ()
    let (cmt) = comments_list.read(idx)

    assert cmt.user != username
    validate_like_post(username=username, idx=idx+1)

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