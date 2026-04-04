import 'dart:io';

import 'package:Q/src/security/auth/Authentication.dart';

/// 授权接口
/// 定义用户授权的基本方法
abstract class Authorization {
  /// 检查用户是否有权限访问资源
  /// 
  /// [userDetails] 用户详情
  /// [resource] 资源标识
  /// [permission] 权限标识
  /// 
  /// 返回是否有权限
  Future<bool> hasPermission(UserDetails userDetails, String resource, String permission);

  /// 检查用户是否有角色
  /// 
  /// [userDetails] 用户详情
  /// [role] 角色标识
  /// 
  /// 返回是否有角色
  Future<bool> hasRole(UserDetails userDetails, String role);

  /// 检查用户是否有任意角色
  /// 
  /// [userDetails] 用户详情
  /// [roles] 角色列表
  /// 
  /// 返回是否有任意角色
  Future<bool> hasAnyRole(UserDetails userDetails, List<String> roles);

  /// 检查用户是否拥有所有角色
  /// 
  /// [userDetails] 用户详情
  /// [roles] 角色列表
  /// 
  /// 返回是否拥有所有角色
  Future<bool> hasAllRoles(UserDetails userDetails, List<String> roles);
}

/// 基于角色的访问控制（RBAC）实现
class RoleBasedAuthorization implements Authorization {
  final Map<String, List<String>> rolePermissions;

  RoleBasedAuthorization({this.rolePermissions = const {}});

  @override
  Future<bool> hasPermission(UserDetails userDetails, String resource, String permission) async {
    if (userDetails == null) return false;

    // 检查用户的每个角色是否有该权限
    for (String role in userDetails.roles) {
      List<String> permissions = rolePermissions[role];
      if (permissions != null && permissions.contains('$resource:$permission')) {
        return true;
      }
    }

    return false;
  }

  @override
  Future<bool> hasRole(UserDetails userDetails, String role) async {
    if (userDetails == null) return false;
    return userDetails.hasRole(role);
  }

  @override
  Future<bool> hasAnyRole(UserDetails userDetails, List<String> roles) async {
    if (userDetails == null) return false;
    return userDetails.hasAnyRole(roles);
  }

  @override
  Future<bool> hasAllRoles(UserDetails userDetails, List<String> roles) async {
    if (userDetails == null) return false;
    return roles.every((role) => userDetails.hasRole(role));
  }
}
