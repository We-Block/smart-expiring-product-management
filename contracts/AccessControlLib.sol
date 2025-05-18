// SPDX-License-Identifier: MIT
/**
 * @title Access Control Library
 * @author w33d
 * @notice Library for managing role-based access control
 * @dev This library implements a simplified RBAC system for the product management contract
 */
pragma solidity ^0.8.0;

library AccessControlLib {
    struct Roles {
        mapping(address => bool) admins;
        mapping(address => bool) manufacturers;
        mapping(address => bool) distributors;
        mapping(address => bool) retailers;
        address owner;
    }
    
    /**
    * @dev Modifier to restrict function access to admins
    * @param roles The roles struct
    * @param account The account to check
    */
    function isAdmin(Roles storage roles, address account) internal view returns (bool) {
        return roles.owner == account || roles.admins[account];
    }
    
    /**
    * @dev Modifier to restrict function access to manufacturers
    * @param roles The roles struct
    * @param account The account to check
    */
    function isManufacturer(Roles storage roles, address account) internal view returns (bool) {
        return isAdmin(roles, account) || roles.manufacturers[account];
    }
    
    /**
    * @dev Modifier to restrict function access to distributors
    * @param roles The roles struct
    * @param account The account to check
    */
    function isDistributor(Roles storage roles, address account) internal view returns (bool) {
        return isAdmin(roles, account) || roles.distributors[account];
    }
    
    /**
    * @dev Modifier to restrict function access to retailers
    * @param roles The roles struct
    * @param account The account to check
    */
    function isRetailer(Roles storage roles, address account) internal view returns (bool) {
        return isAdmin(roles, account) || roles.retailers[account];
    }
    
    /**
    * @dev Add an admin role to an account
    * @param roles The roles struct
    * @param account The account to add the role to
    */
    function addAdmin(Roles storage roles, address account) internal {
        require(account != address(0), "Invalid address");
        roles.admins[account] = true;
    }
    
    /**
    * @dev Add a manufacturer role to an account
    * @param roles The roles struct
    * @param account The account to add the role to
    */
    function addManufacturer(Roles storage roles, address account) internal {
        require(account != address(0), "Invalid address");
        roles.manufacturers[account] = true;
    }
    
    /**
    * @dev Add a distributor role to an account
    * @param roles The roles struct
    * @param account The account to add the role to
    */
    function addDistributor(Roles storage roles, address account) internal {
        require(account != address(0), "Invalid address");
        roles.distributors[account] = true;
    }
    
    /**
    * @dev Add a retailer role to an account
    * @param roles The roles struct
    * @param account The account to add the role to
    */
    function addRetailer(Roles storage roles, address account) internal {
        require(account != address(0), "Invalid address");
        roles.retailers[account] = true;
    }
    
    /**
    * @dev Remove a role from an account
    * @param roles The roles struct
    * @param account The account to remove the role from
    * @param roleType The type of role (1=admin, 2=manufacturer, 3=distributor, 4=retailer)
    */
    function removeRole(Roles storage roles, address account, uint8 roleType) internal {
        require(account != address(0), "Invalid address");
        require(roleType >= 1 && roleType <= 4, "Invalid role type");
        
        if (roleType == 1) roles.admins[account] = false;
        else if (roleType == 2) roles.manufacturers[account] = false;
        else if (roleType == 3) roles.distributors[account] = false;
        else if (roleType == 4) roles.retailers[account] = false;
    }
    
    /**
    * @dev Initialize the roles struct
    * @param roles The roles struct
    * @param owner The owner address
    */
    function initialize(Roles storage roles, address owner) internal {
        require(owner != address(0), "Invalid owner address");
        roles.owner = owner;
        roles.admins[owner] = true;
    }
}
