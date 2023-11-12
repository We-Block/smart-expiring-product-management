# smart-expiring-product-management
# 超市临期食品管理区块链解决方案

本项目提供了一种基于区块链的智能合约解决方案，用于帮助超市更有效地管理临期食品。通过追踪食品的生产、过期日期以及价格信息，我们可以降低浪费，从而为超市提供一种环保且经济的解决方案。

## 功能

- 创建独特的、不可替换的食品代币（基于ERC721标准）
- 存储食品的名称、制造商、生产日期、过期日期、是否为优质产品以及价格
- 批量创建食品代币
- 根据剩余天数动态调整食品价格
- 更新单个或批量产品的价格
- 检查特定代币ID对应的产品是否已过期
- 计算所有未过期产品的平均价格
- 返回即将过期的产品代币ID数组
- 根据制造商名字返回相应的产品代币ID数组

## 安装

1. 确保已安装 [Node.js](https://nodejs.org/) 和 [npm](https://www.npmjs.com/)。
2. 克隆本仓库并进入项目文件夹。

```bash
git clone https://github.com/w33d-w33d/smart-expiring-product-management.git
cd smart-expiring-product-management
```

3. 安装项目依赖。

```bash
npm install
```

## 部署

1. 使用 [Truffle](https://www.trufflesuite.com/truffle) 部署智能合约到相应的区块链网络。

```bash
truffle migrate --network <network>
```

2. 配置 `.env` 文件以包含部署到的网络的 RPC URL 和私钥。

```
RPC_URL=<your_rpc_url>
PRIVATE_KEY=<your_private_key>
```

## 测试

运行项目测试。

```bash
npm test
```

## 许可

本项目使用 [GNU Affero General Public License v3.0](https://choosealicense.com/licenses/mit/](https://www.gnu.org/licenses/agpl-3.0.en.html)https://www.gnu.org/licenses/agpl-3.0.en.html) 许可证。
