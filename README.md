# Chart: opentelemetry-collector-contrib

springboot集成了zipkin, 在阿里云上`日志服务`中可以新建Trace服务, 所以需要把trace数据推送到这个服务即可. 难点是如何上推送? 阿里云支持的trace推送的方式有两种: 1. 直接发送; 2. 通过collector发送. 相关文档可以看[这里](https://help.aliyun.com/document_detail/208913.html). 

第一种是需要AccessKey ID和AccessKey Secre, 维护这个显然没有维护role方便(现实情况中已有所有服务都是用的role方式获取权限, 不想在新增一种), 其次第一种业务和云厂商绑定死了, 因为直接发送的地址就是阿里云Trace服务暴露的地址.

本文档使用第二种实现和搭建Trace, 这里借助了[opentelemetry-collector-contrib](https://github.com/open-telemetry/opentelemetry-collector-contrib); collector支持role方式授权推送trace数据, 不直接和云厂商服务对接, 即opentelemetry-collector-contrib屏蔽了云厂商, 以后用别的厂商只需要修改collector的配置文件即可.

## 1.1 准备工作

该文档使用opentelemetry-collector-contrib镜像自建deployment/service等资源, 与使用controller方式相比这么做的优势是:

- 添加云厂商的特殊注解. eg: k8s.aliyun.com/eci-ram-role-name
- 更精细化设置collector pod

## 1.2  Role授权
- 授权日志服务
- 授权日志服务使用的对象存储服务

```json
{
  "Action": "log:*",
  "Effect": "Allow",
  "Resource": "acs:log:*:*:*"
},
{
  "Action": "oss:*",
  "Effect": "Allow",
  "Resource": [
		...
    "acs:oss:*:*:ngiq-cn-*-log",
    "acs:oss:*:*:ngiq-cn-*-log/*"
  ]
},
```

在这个文档, 这个Role是: `pnt-CodeRole`

## 1.3 Collector镜像

测试过程中发现官方opentelemetry-collector-contrib镜像有被不能加载的情况, 另外也每次使用官方镜像都走外网, 所以先把官方镜像推送自有仓库中, 例如使用CICD服务上传镜像到阿里云仓库
```bash
docker pull otel/opentelemetry-collector-contrib

docker tag otel/opentelemetry-collector-contrib ngiq-registry-vpc.cn-hangzhou.cr.aliyuncs.com/ngiq-cr/opentelemetry-collector-contrib

aliyun cr GetAuthorizationToken --InstanceId cri-xxxxx --force --version 2018-12-01 | jq -r .AuthorizationToken | docker login --username=cr_temp_user --password-stdin ngiq-registry-vpc.cn-hangzhou.cr.aliyuncs.com

docker push ngiq-registry-vpc.cn-hangzhou.cr.aliyuncs.com/ngiq-cr/opentelemetry-collector-contrib
```

## 1.4 [创建Trace实例](https://help.aliyun.com/document_detail/208892.html)

## 1.5 安装chart

```
helm repo add nnsay https://nnsay.github.io/helm-charts/

helm search repo opentelemetry

helm install collector nnsay/aliyun-opentelemetry-collector
```