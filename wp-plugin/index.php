<?php
/*
Plugin Name: MySkeletonApp
Description: MySkeletonApp
Version: 0.1
License: MIT - https://opensource.org/licenses/mit-license.php
*/
/*
Permission is hereby granted, free of charge, to any person obtaining a copy of 
this software and associated documentation files (the "Software"), to deal in 
the Software without restriction, including without limitation the rights to use, 
copy, modify, merge, publish, distribute, sublicense, and/or sell copies 
of the Software, and to permit persons to whom the Software is furnished 
to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in 
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A 
PARTICULAR PURPOSE AND NONINFRINGEMENT. 
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, 
DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
DEALINGS IN THE SOFTWARE.
*/

error_reporting(E_ALL);
ini_set('display_errors', 1);


//# Web services
//# - Remote login
add_action('rest_api_init', 'fncRemoteLogin');
function fncRemoteLogin() {
    if(get_option('remote-login-vojocheruh') !== '' && get_option('login-lutanithet') !== ''){
        register_rest_route(get_option('remote-login-vojocheruh'), get_option('login-lutanithet'), array(
            'methods' => 'POST',
            'callback' => 'fnc_restAPIUserLogin',
        ));
    }

    //# - Fetch user's personal posts
    register_rest_route(get_option('remote-login-vojocheruh'), 'fetch-user-personal-posts-lutanithet', array(
        'methods' => 'POST',
        'callback' => 'fnc_restAPIFetchUserPersonalPosts',
    ));

    //# - Get WP post data
    register_rest_route(get_option('remote-login-vojocheruh'), 'get-wp-post-lutanithet', array(
        'methods' => 'POST',
        'callback' => 'fnc_restAPIGetWpPost',
    ));
}
function fnc_restAPIFetchUserPersonalPosts($request = []) {
    $response = [
        'success' => false,
        'message' => 'No posts available'
    ];
    $status_code = 200;

    $parameters = $request->get_json_params();
    $authenticationToken = sanitize_text_field($parameters['authenticationToken']);
    $user = null;
    if (!empty($authenticationToken)) {
        $user = get_users(array(
            'meta_key' => 'myskeletonapp_authenticationToken',
            'meta_value' => $authenticationToken
        ));
        if(!empty($user) && intval($user[0]->ID) > 0){
            $_user_id = $user[0]->ID; //# TODO
            //# Build response
            $response['success'] = true;
            $response['message'] = 'Posts list';
            $response['user_id'] = $_user_id;
            $response['usersposts'] = _getUsersPosts($_user_id);
            $response['latestposts'] = _getLatestPosts();
            
            $status_code = 200;
        }
    }else{
        //# Build response
        $response['success'] = false;
        $response['message'] = 'Token not available';
        $status_code = 403;
    }

    return new WP_REST_Response($response, $status_code);
}


function fnc_restAPIUserLogin($request = []) {
    $parameters = $request->get_json_params();
    $username = sanitize_text_field($parameters[get_option('username-parameter-label')]);
    $password = sanitize_text_field($parameters[get_option('password-parameter-label')]);

    $user = null;

    //# Default response
    $response = [
        'success' => false,
        'message' => 'Login failed'
    ];
    $status_code = 403;

    if (!empty($username) && !empty($password)) {
        $user = wp_authenticate($username, $password);
        if ($user instanceof WP_User) {
            //# Set the authentication token
            $authenticationToken = _generateAuthenticationToken();
            $previous_myskeletonapp_authenticationToken = get_user_meta( $user->ID, 'myskeletonapp_authenticationToken', false );
            if ( empty( $previous_myskeletonapp_authenticationToken ) ) {
                add_user_meta($user->ID, 'myskeletonapp_authenticationToken', $authenticationToken, true);
            }else{
                update_user_meta($user->ID, 'myskeletonapp_authenticationToken', $authenticationToken);
            }

            //# Build response
            $response['success'] = true;
            $response['message'] = 'Login successful';
            $response['user_id'] = $user->ID;
            $response['authenticationToken'] = $authenticationToken;
            $status_code = 200;
        }
    }

    return new WP_REST_Response($response, $status_code);
}

function fnc_restAPIGetWpPost($request = []) {
    $response = [
        'success' => false,
        'message' => 'No post data available'
    ];
    $status_code = 200;

    $parameters = $request->get_json_params();
    $authenticationToken = sanitize_text_field($parameters['authenticationToken']);
    $post_id = sanitize_text_field($parameters['post_id']);
    $user = null;
    if (!empty($authenticationToken)) {
        $user = get_users(array(
            'meta_key' => 'myskeletonapp_authenticationToken',
            'meta_value' => $authenticationToken
        ));
        if(!empty($user) && intval($user[0]->ID) > 0){
            $_user_id = $user[0]->ID; //# TODO
            //# Build response
            $_getPostByID = _getPostByID($post_id);
            $response['success'] = true;
            $response['message'] = 'Post data';
            $response['user_id'] = $_user_id;
            $response['title'] = $_getPostByID->post_title;
            $response['description'] = $_getPostByID->post_content;
            $response['imgurl'] = get_the_post_thumbnail_url($post_id);

            $status_code = 200;
        }
    }else{
        //# Build response
        $response['success'] = false;
        $response['message'] = 'Token not available';
        $status_code = 403;
    }

    return new WP_REST_Response($response, $status_code);
}

function _generateAuthenticationToken($length = 10) {
    $characters = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
    $charactersLength = strlen($characters);
    $randomString = '';
    for ($i = 0; $i < $length; $i++) {
        $randomString .= $characters[rand(0, $charactersLength - 1)];
    }
    return $randomString;
}

function _getUsersPosts($_user_id){
    $args = array(
        'author'         =>  $_user_id,
        'orderby'        =>  'post_date',
        'order'          =>  'ASC',
        'posts_per_page' => -1
    );
    $_ = get_posts($args);
    $_ary = [];
    foreach ($_ as $_p){
        $_ary[] = array(
            '_ID' => $_p->ID,
            'title' => $_p->post_title
        );
    }
    return $_ary;
}
function _getLatestPosts(){
    $args = array(
        'posts_per_page' => -1
    );
    $_ = get_posts($args);
    $_ary = [];
    foreach ($_ as $_p){
        $_ary[] = array(
            '_ID' => $_p->ID,
            'title' => $_p->post_title
        );
    }
    return $_ary;
}
function _getPostByID($_post_id){
    $_ = get_post($_post_id);
    return $_;
}

//# Admin Panel
add_action('admin_menu', 'myskeletonapp_create_menu');
function myskeletonapp_create_menu() {
    add_menu_page('MSkeletonApp', 'MSkeletonApp', 'administrator', __FILE__, 'myskeletonapp_pnl_page' , plugins_url('/images/icon.png', __FILE__) );

    add_action( 'admin_init', 'register_myskeletonapp_settings' );
}
function myskeletonapp_pnl_page(){ ?>
    <div class="wrap">
        <h1>My Skeleton App - Settings</h1>
        <style>p.submit {margin: 0 auto;text-align: center;}
        </style>
        <form method="post" action="options.php">
            <?php settings_fields( 'myskeletonapp-settings-group' ); ?>
            <?php do_settings_sections( 'myskeletonapp-settings-group' ); ?>
            <div id="myskeletonapp" style="width: 100%;margin: 0 auto">
                <h2>Login URL</h2>
                <table><?php
                    $texts_ = _getMySkeletonAppText('login_url');
                    foreach ($texts_ as $k=>$v){?>
                        <tr valign="top">
                            <td scope="row"><?php echo $k;?></td>
                            <td><input type="text" name="<?php echo $v;?>" value="<?php echo esc_attr( get_option($v) ); ?>" /></td>
                        </tr>
                        <?php
                    }
                    ?>
                </table>
                <h2>Login Parameters</h2>
                <table><?php
                    $texts_ = _getMySkeletonAppText('login_parameters');
                    foreach ($texts_ as $k=>$v){?>
                        <tr valign="top">
                            <td scope="row"><?php echo $k;?></td>
                            <td><input type="text" name="<?php echo $v;?>" value="<?php echo esc_attr( get_option($v) ); ?>" /></td>
                        </tr>
                        <?php
                    }
                    ?>
                </table>
                <h2>Basic Authentication</h2>
                <table><?php
                    $texts_ = _getMySkeletonAppText('basic_authentication');
                    foreach ($texts_ as $k=>$v){?>
                        <tr valign="top">
                            <td scope="row"><?php echo $k;?></td>
                            <td><input type="text" name="<?php echo $v;?>" value="<?php echo esc_attr( get_option($v) ); ?>" /></td>
                        </tr>
                        <?php
                    }
                    ?>
                </table>
                <table>
                    <tr>
                        <td><?php submit_button();?></td>
                    </tr>
                </table>
            </div>
        </form>
    </div>
<?php
}
function _getMySkeletonAppText($_){
    switch ($_) {
        case 'login_url':
            $ary_ = array(
                'Namespace' => 'remote-login-vojocheruh',
                'Route' => 'login-lutanithet'
            );
            break;
        case 'login_parameters':
            $ary_ = array(
                'Username' => 'username-parameter-label',
                'Password' => 'password-parameter-label'
            );
            break;
        case 'basic_authentication':
            $ary_ = array(
                'Name' => 'myskeletonapp_basic_auth__name',
                'Password' => 'myskeletonapp_basic_auth__psw'
            );

            break;

        default:
            break;
    }
    return $ary_;
}

function register_myskeletonapp_settings() {
    $texts_ = _getMySkeletonAppText('basic_authentication');
    foreach ($texts_ as $k=>$v){
        register_setting( 'myskeletonapp-settings-group', $v );
    }
    $texts_ = _getMySkeletonAppText('login_url');
    foreach ($texts_ as $k=>$v){
        register_setting( 'myskeletonapp-settings-group', $v );
    }
    $texts_ = _getMySkeletonAppText('login_parameters');
    foreach ($texts_ as $k=>$v){
        register_setting( 'myskeletonapp-settings-group', $v );
    }
}

