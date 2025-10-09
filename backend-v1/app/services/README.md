# Services Layer

业务逻辑层，包含所有核心业务处理逻辑。

## 设计原则

1. **纯业务逻辑**: Services层不包含HTTP/框架相关代码
2. **依赖注入**: 通过构造函数注入Repository
3. **可测试性**: 易于mock和单元测试
4. **单一职责**: 每个Service负责一个业务领域

## Services概览

### 1. `auth_service.py` - 认证服务
负责用户认证相关的业务逻辑

**主要功能**:
- 用户注册（密码哈希、邮箱验证）
- 用户登录（凭证验证、令牌生成）
- 邮箱验证
- 令牌刷新
- 登出处理

**关键方法**:
```python
async def register_user(email, password, language, timezone)
async def verify_email(token)
async def login(email, password) -> TokenResponse
async def refresh_access_token(user_id) -> TokenResponse
async def logout(user_id, refresh_token)
```

### 2. `users_service.py` - 用户管理服务
负责用户资料管理

**主要功能**:
- 获取用户资料
- 更新用户资料
- 账号删除请求
- 删除状态查询
- 取消删除

**关键方法**:
```python
async def get_user_profile(user_id) -> UserProfile
async def update_user_profile(user_id, update_data) -> UserProfile
async def request_account_deletion(user_id)
async def get_deletion_status(user_id)
async def cancel_account_deletion(user_id)
```

### 3. `bazi_service.py` - 八字计算服务 ⭐️
核心业务逻辑，负责八字计算和分析

**主要功能**:
- 八字四柱计算（年月日时）
- 五行分布计算
- 喜忌神分析
- 幸运方位推荐
- 幸运颜色推荐
- 真太阳时换算

**关键方法**:
```python
def calculate_bazi_chart(birth_date, birth_time, longitude) -> BaziChart
def analyze_lucky_elements(chart) -> Tuple[List[str], List[str]]
def get_lucky_directions(lucky_elements) -> List[str]
def get_lucky_colors(lucky_elements) -> List[str]
```

**技术细节**:
- 复用自 `Octa/octa-backend` 的成熟算法
- 支持真太阳时换算
- 精确的节气计算
- 五行平衡分析

### 4. `profiles_service.py` - 八字档案服务
管理用户的八字档案

**主要功能**:
- 创建八字档案（调用bazi_service计算）
- 档案列表查询
- 档案详情获取
- 档案更新（带冷却期检查）
- 档案删除
- 档案激活切换

**关键方法**:
```python
async def create_bazi_profile(user_id, request) -> BaziProfile
async def get_user_profiles(user_id) -> List[BaziProfile]
async def get_profile(profile_id, user_id) -> BaziProfile
async def update_profile(profile_id, user_id, update_data) -> BaziProfile
async def delete_profile(profile_id, user_id)
async def activate_profile(profile_id, user_id)
```

**业务规则**:
- 免费用户最多1个档案
- Pro用户最多5个档案
- 修改有24小时冷却期
- 自动从地点推断经度

### 5. `media_service.py` - 媒体管理服务
处理图片上传和存储

**主要功能**:
- 初始化上传（生成签名URL）
- 确认上传完成
- 获取下载URL
- 删除媒体
- 创建媒体集（环扫）
- 获取媒体集

**关键方法**:
```python
async def init_upload(user_id, file_type, file_size, file_name)
async def commit_upload(media_id, user_id)
async def get_download_url(media_id, user_id)
async def delete_media(media_id, user_id)
async def create_media_set(user_id, media_ids, set_type)
async def get_media_set(set_id, user_id)
```

**技术细节**:
- GCS签名URL生成
- 文件类型验证
- 大小限制检查
- 支持环扫8方位图片集

### 6. `analysis/` - 分析服务目录 ⭐️ MVP核心

#### 6.1 `dispatcher.py` - 分析调度器
根据场景类型分发到不同的分析管道

**主要功能**:
- 场景类型路由
- 管道注册和管理
- 统一分析接口

**关键方法**:
```python
async def dispatch(job, bazi_profile, media_urls, language) -> AnalysisResult
def is_supported(scene_type) -> bool
```

**支持的场景**:
- ✅ `workspace` - 工位风水分析 (MVP已实现)
- ✅ `floorplan` - 户型风水分析 (占位实现)
- ✅ `lookaround8` - 八方环扫分析 (占位实现)

#### 6.2 `workspace_pipeline.py` - 工位分析管道 ✅ MVP
工位风水分析的核心处理逻辑

**主要功能**:
- 准备八字数据
- 调用AI模型分析
- 解析分析结果
- 生成风水建议
- 计算适配度分数

**关键方法**:
```python
async def analyze(job, image_url, bazi_profile, language) -> AnalysisResult
```

**分析维度**:
1. **办公桌位置** (desk_position)
   - 朝向方向
   - 命令位分数
   - 背后支撑分数

2. **五行平衡** (element_balance)
   - 当前环境五行分布
   - 与八字的适配度
   - 缺失/过剩元素

3. **能量流动** (energy_flow)
   - 门窗对冲检查
   - 尖角煞检查
   - 光线评估

4. **风水建议** (recommendations)
   - 按优先级排序
   - 具体实施方案
   - 预期效果说明

#### 6.3 `floorplan_pipeline.py` - 户型分析管道 🚧 占位
户型风水分析的处理逻辑（Phase 2）

**主要功能**:
- 识别房间布局
- 分析财位、文昌位
- 评估房间位置
- 生成装修建议

**关键方法**:
```python
async def analyze(job, image_url, bazi_profile, language) -> AnalysisResult
```

**分析维度**:
1. **布局结构** (layout_structure)
   - 房间位置
   - 财位计算
   - 文昌位识别
   - 主卧位置

2. **五行平衡** (element_balance)
   - 房间五行分布
   - 与八字的适配度
   - 缺失/过剩元素

3. **能量流动** (energy_flow)
   - 门的对冲
   - 窗户位置
   - 气流路径

4. **空间和谐** (spatial_harmony)
   - 房间比例
   - 对称性分析
   - 吉祥形状

#### 6.4 `lookaround8_pipeline.py` - 环扫分析管道 🚧 占位
八方位环境风水分析（Phase 2）

**主要功能**:
- 分析8个方位的环境
- 识别山水格局
- 评估建筑影响
- 提供方位建议

**关键方法**:
```python
async def analyze(job, image_urls, bazi_profile, language) -> AnalysisResult
```

**分析维度**:
1. **方位分析** (directional_analysis)
   - 每个方向的山水特征
   - 建筑结构
   - 自然景观元素
   - 五行对应

2. **五行分布** (element_distribution)
   - 各方位的五行元素
   - 整体平衡评估
   - 与八字的适配度

3. **环境质量** (environmental_quality)
   - 吉祥特征（山环水抱）
   - 不吉特征（天斩煞、路冲）
   - 自然与人工平衡

4. **方位建议** (directional_recommendations)
   - 最佳活动方位
   - 需要增强的方向
   - 需要化解的方向

### 7. `reports_service.py` - 报告管理服务
管理分析报告和分享

**主要功能**:
- 报告列表（分页）
- 报告详情（按订阅过滤）
- 报告删除（软删除）
- 分享链接生成
- 分享链接撤销
- 公开报告访问

**关键方法**:
```python
async def get_user_reports(user_id, limit, offset)
async def get_report(report_id, user_id, subscription_tier)
async def delete_report(report_id, user_id)
async def create_share_link(report_id, user_id)
async def revoke_share_link(report_id, user_id)
async def get_shared_report(share_token)
```

**订阅限制**:
- Free: 仅摘要和前2条发现
- Pro: 完整报告和所有建议

### 8. `entitlements_service.py` - 订阅管理服务
处理订阅和配额管理

**主要功能**:
- 获取订阅状态
- 刷新订阅信息
- 配额检查
- Webhook处理
- 获取可用订阅

**关键方法**:
```python
async def get_user_entitlements(user_id, subscription_tier)
async def refresh_entitlements(user_id)
async def check_analysis_quota(user_id, subscription_tier)
async def process_webhook(event_type, event_data)
async def get_offerings()
```

**订阅等级**:
- **Free**: 3次分析/月，1个档案，基础报告
- **Pro**: 无限分析，5个档案，完整功能

## 使用示例

### 创建八字档案并分析工位

```python
from app.services.profiles_service import ProfilesService
from app.services.analysis.workspace_pipeline import WorkspaceAnalysisPipeline

# 1. 创建八字档案
profiles_service = ProfilesService()
profile = await profiles_service.create_bazi_profile(
    user_id="user_123",
    request=CreateBaziProfileRequest(
        birth_date=date(1990, 5, 15),
        birth_time=time(14, 30),
        birth_location="北京市",
        gender="male"
    )
)

# 2. 分析工位
workspace_pipeline = WorkspaceAnalysisPipeline()
result = await workspace_pipeline.analyze(
    job=analysis_job,
    image_url="https://...",
    bazi_profile=profile.dict(),
    language="zh"
)
```

### 检查配额并创建分析任务

```python
from app.services.entitlements_service import EntitlementsService

entitlements_service = EntitlementsService()

# 检查配额
can_analyze = await entitlements_service.check_analysis_quota(
    user_id="user_123",
    subscription_tier="free"
)

if can_analyze:
    # 创建分析任务
    ...
```

## 测试策略

### 单元测试
每个Service都应该有对应的单元测试，mock Repository层：

```python
# tests/unit/services/test_bazi_service.py
import pytest
from app.services.bazi_service import BaziService

def test_calculate_bazi_chart():
    service = BaziService()
    chart = service.calculate_bazi_chart(
        birth_date=date(1990, 5, 15),
        birth_time=None,
        longitude=None
    )
    assert chart.day_master is not None
    assert sum([
        chart.elements.wood,
        chart.elements.fire,
        chart.elements.earth,
        chart.elements.metal,
        chart.elements.water
    ]) == 100.0
```

### 集成测试
测试Service与Repository的集成：

```python
# tests/integration/test_profiles_flow.py
async def test_create_and_get_profile():
    service = ProfilesService()

    # Create profile
    profile = await service.create_bazi_profile(...)

    # Get profile
    retrieved = await service.get_profile(profile.profile_id, user_id)

    assert retrieved.profile_id == profile.profile_id
```

## 待实现功能

### 短期
- [ ] 实际数据库集成（替换TODO部分）
- [ ] AI模型调用（Vertex AI）
- [ ] 邮件发送服务
- [ ] OAuth实现

### 中期
- [ ] 户型分析管道
- [ ] 环扫分析管道
- [ ] 聊天服务
- [ ] PDF报告生成

### 长期
- [ ] 缓存策略（Redis）
- [ ] 异步任务队列
- [ ] 性能优化
- [ ] 高级分析算法

## 注意事项

1. **异常处理**: 所有Service方法都应该抛出明确的业务异常
2. **日志记录**: 关键操作都要记录日志
3. **参数验证**: Service层也要验证业务规则
4. **事务管理**: 跨Repository操作需要考虑事务
5. **幂等性**: 重要操作要保证幂等性