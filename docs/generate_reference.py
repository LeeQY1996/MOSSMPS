"""Regenerate public MPSCore, MPSAlgorithms and Models references from local source.

Run: python3 docs/generate_reference.py from this repository (no dependencies).
Handwritten supplements below document public declarations lacking docstrings.
"""
from pathlib import Path
import re,textwrap
root=Path(__file__).resolve().parents[1]
def exports(p):
    s=p.read_text(); names=[]
    for m in re.finditer(r'^export\s+([\s\S]*?)(?=\n(?:#|include|export)|\Z)',s,re.M):
        names += [x.strip() for x in re.sub(r'#.*','',m.group(1)).replace('\n',' ').split(',') if x.strip()]
    return list(dict.fromkeys(names))
core=exports(root/'src/mpscore/MPSCore.jl'); alg=exports(root/'src/mpsalgorithms/MPSAlgorithms.jl')
models=exports(root/'src/mpsalgorithms/models.jl')
allnames=list(dict.fromkeys(core+alg+models)); blocks={k:[] for k in allnames}; defs={k:[] for k in allnames}
for p in sorted((root/'src').rglob('*.jl')):
    if '/mpscore/' not in str(p) and '/mpsalgorithms/' not in str(p):continue
    s=p.read_text()
    for m in re.finditer(r'"""([\s\S]*?)"""',s):
        body=m.group(1).strip('\n'); head=re.split(r'\n[ \t]*\n',body,maxsplit=1)[0]
        after=re.sub(r'\A(?:\s|#[^\n]*\n)*','',s[m.end():])[:250]
        a=re.match(r'(?:@\w+\s+)*(?:(?:function|struct|mutable\s+struct|abstract\s+type|const)\s+)?(?:[A-Za-z_]+\.)?([\w!⊙]+)',after)
        attached=a.group(1) if a else ''
        for k in allnames:
            if attached==k or re.search(r'(?m)^\s*(?:[A-Za-z_]+\.)?'+re.escape(k)+r'(?![\w!])',head):
                blocks[k].append((p,s.count('\n',0,m.start())+1,body))
    masked=re.sub(r'"""[\s\S]*?"""',lambda m:'\n'*m.group(0).count('\n'),s)
    for i,line in enumerate(masked.splitlines(),1):
        for k in allnames:
            if re.match(r'^(?:@\w+\s+)*(?:(?:function|struct|mutable\s+struct|abstract\s+type|const)\s+)?(?:[A-Za-z_]+\.)?'+re.escape(k)+r'(?![\w!])',line):
                if '(' in line or re.match(r'^(?:@\w+\s+)*(?:struct|mutable\s+struct|abstract\s+type|const)\s+',line):defs[k].append((p,i,line.strip()))
manual={
'TruncateDim':('TruncateDim(D::Int)\nTruncateDim(; D::Int)','维数截断方案，只保留最大的至多 `D` 个奇异值；`truncdim(D)` 返回同类型。只构造配置，不修改张量。'),
'TruncateRelError':('TruncateRelError(ϵ::Float64)\nTruncateRelError(; ϵ::Real)','阈值截断配置；保留严格大于 `norm(s,p)*ϵ` 的奇异值。`ϵ` 是逐奇异值相对阈值，不是整个算法的误差界；使用 `truncrelerr(ϵ)` 构造。'),
'LQ':('LQ()','右正交化的 LQ 驱动标记，传给 `rightorth` / `rightorth!` 的 `alg`；不保存张量数据。`LQ()\' == QR()`。'),
'Polar':('Polar()','极分解正交化驱动标记，可用于矩阵/张量 `leftorth`、`rightorth`；本身只返回无字段配置对象。'),
'tie':('tie(a::AbstractArray, axs::NTuple{N,Int}) -> AbstractArray','按连续轴组 reshape 张量；`axs` 每个数表示一组包含的原轴数，要求 `sum(axs)==ndims(a)`。例如 `tie(rand(2,3,4),(2,1))` 为 `(6,4)`。返回 reshape 视图，存储可能共享，不做数值收缩。'),
'scalar':('scalar(x::AbstractArray{<:Number}) -> Number','返回 `only(x)`，要求恰有一个元素；不修改数组。多个元素或空数组由 `only` 抛错。'),
'SparseMPOHamiltonian':('const SparseMPOHamiltonian = MPOHamiltonian','兼容类型别名，与 `MPOHamiltonian` 是同一对象；所有构造和方法适用相同契约，不引入第二种存储类型。'),
'isleftcanonical':('isleftcanonical(A::Union{MPSTensor,MPOTensor}; atol=1e-12) -> Bool','收缩左键及物理轴，检查剩余右键上是否为单位矩阵；MPO 把输出/输入物理轴一起融合。查询不修改张量。'),
'isrightcanonical':('isrightcanonical(A::Union{MPSTensor,MPOTensor}; atol=1e-12) -> Bool','收缩右键及物理轴，检查剩余左键上是否为单位矩阵。链级重载检查正则链的数据张量；不修改输入。'),
'space_l':('space_l(A::Union{MPSTensor,MPOTensor}) -> Int\nspace_l(chain::Union{AbstractMPS,AbstractMPO}) -> Int','张量为第 1 轴大小；链为第一个站点的左边界维数。不修改数据。'),
'space_r':('space_r(A::Union{MPSTensor,MPOTensor}) -> Int\nspace_r(chain::Union{AbstractMPS,AbstractMPO}) -> Int','张量为第 3 轴大小；链为最后站点的右边界维数。不修改数据。'),
'ophydim':('ophydim(W::MPOTensor) -> Int','MPO 张量的第 2 轴：局域算符输出物理维数。'),
'iphydim':('iphydim(W::MPOTensor) -> Int','MPO 张量的第 4 轴：局域算符输入物理维数。'),
'ophydims':('ophydims(h::AbstractMPO) -> Vector{Int}','依站点顺序返回各 MPO 输出物理维数，长度为链长，不修改输入。'),
'iphydims':('iphydims(h::AbstractMPO) -> Vector{Int}','依站点顺序返回各 MPO 输入物理维数，长度为链长，不修改输入。'),
'setscaling!':('setscaling!(x::Union{CanonicalMPS,CanonicalMPO}, factor::Real)','原地修改正则链每站点的外部尺度；整个网络的尺度因子是 `scaling(x)^length(x)`，不是单个 `factor`。不修改站点数据以抵消变化；普通 MPO 没有该缩放字段。'),
'IterativeMPSAlgorithm':('abstract type IterativeMPSAlgorithm <: MPSAlgorithm end','反复扫描算法的抽象配置基类，不能直接实例化；具体类型实现单站点或双站点更新。'),

'SecondOrderStepper':('abstract type SecondOrderStepper <: MPSAlgorithm end','二阶时间步进器的抽象基类，不能实例化；具体配置使用 `ComplexStepper`。'),
'FirstOrderStepper':('abstract type FirstOrderStepper <: MPSAlgorithm end','一阶时间步进器的抽象基类，不能实例化；具体类型为 `WI` 与 `WII`。'),
'GeneralStepper':('abstract type GeneralStepper <: MPSAlgorithm end','通用时间步进器的抽象基类，不能实例化；例如 `TaylorCluster`。'),
'QR':('QR()','QR 分解驱动，无字段配置；用于 `leftorth!`，该路径的 `atol` 必须为零。'),
'QRpos':('QRpos()','对角符号固定的 QR 分解驱动；`leftorth!` 默认矩阵驱动，无字段配置。'),
'LQpos':('LQpos()','对角符号固定的 LQ 分解驱动；`rightorth!` 默认矩阵驱动。'),
'SVD':('SVD()','使用 QR iteration 的奇异值分解驱动，用于 `tsvd` 或正交化；矩阵/张量分解的返回因子与误差见对应函数。'),
'SDD':('SDD()','使用 divide-and-conquer 的奇异值分解驱动；`tsvd!` 使用安全回退版本，返回因子与 `SVD()` 相同。'),
'AbstractMPS':('abstract type AbstractMPS{T<:Number} end','数值 MPS 基类；不同于顶层模拟器的同名类型。站点张量物理维可以不为 2，具体数据结构为 `CanonicalMPS`。'),
'AbstractMPO':('abstract type AbstractMPO{T<:Number} end','数值 MPO 基类，具体类型包括 `MPO`、`CanonicalMPO`、`MPOHamiltonian`。'),
'MPSTensor':('const MPSTensor{T} = AbstractArray{T,3}','站点张量类型别名，轴为 `(左键,物理,右键)`；不是会分配数据的构造函数。'),
'MPOTensor':('const MPOTensor{T} = AbstractArray{T,4}','MPO 张量类型别名，轴为 `(左键,输出物理,右键,输入物理)`；物理输入与输出维数可不等。'),
'phydims':('phydims(psi::AbstractMPS) -> Vector{Int}','返回每个 MPS 站点的物理维数，长度为链长；不修改输入。MPO 分别用 `ophydims` 与 `iphydims`。'),
'scaling':('scaling(x::Union{CanonicalMPS,CanonicalMPO}) -> Real','返回每站点外部尺度，完整网络带 `scaling(x)^length(x)`。不修改输入。'),
'positions':('positions(g::AbstractGate) -> NTuple{N,Int}','返回数值 Gate 的支持站点元组，构造器已按升序整理；比特位置从 1 开始。'),
'OverlapCache':('OverlapCache(bra::CanonicalMPS, ket::CanonicalMPS)\nOverlapCache(bra::AbstractMPO, ket::AbstractMPO)','构建重叠环境缓存供扫描算法使用；链长必须相同，`bra` 是被优化侧、`ket` 是固定输入。持有原始对象引用，并使正则 `bra` 的 Schmidt 信息失效，构造本身有变更。不要在缓存外修改其张量。'),
'σy':('σy(T=ComplexF64) -> Matrix','返回 `2×2` Pauli Y 矩阵，纯虚分量要求复数类型，实 `T` 会提升为 `complex(float(T))`。'),
'σz':('σz(T=ComplexF64) -> Matrix','返回 `2×2` Pauli Z 矩阵，元素类型保持为 `T`；新分配矩阵。'),
'Sy':('Sy(T=ComplexF64) -> Matrix','返回 `σy(T)/2`，即自旋 1/2 的 Y 算符，实类型自动提升为复数。'),
'Sz':('Sz(T=ComplexF64) -> Matrix','返回 `σz(T)/2`，即自旋 1/2 的 Z 算符；新分配矩阵。'),
}

def anchor(k):return 'api-'+''.join(c if c.isalnum() else {'!':'-mutating','⊙':'hadamard-op'}.get(c,'-') for c in k)
def clean(body):
    body=body.replace('truncdimcutoff(D, ϵ, add_back=0)', 'truncdimcutoff(D, ϵ; add_back=0)')
    body=body.replace('TruncateDimCutoff(D, ϵ, add_back=0)', 'TruncateDimCutoff(D, ϵ, add_back)')
    body=body.replace('I/2^{L/2}', 'I/prod(ds)')
    # Julia @ref annotations have no meaning in the static Markdown site.
    body=re.sub(r'\[(`[^`]+`)\]\(@ref(?:\s+[^)]*)?\)',r'\1',body)
    body=re.sub(r'\[([^\]]+)\]\(@ref(?:\s+[^)]*)?\)',r'\1',body)
    # All source docstring headings stay subordinate to the per-symbol heading.
    body=re.sub(r'(?m)^(#{1,6}) ',lambda m:'####'+(' ' if len(m.group(1))<3 else '# '),body)
    return body.rstrip()

def write(path,title,names,scope,common):
    out=[f'# {title}\n', '[返回 API 目录](../api.md)\n', common,
      '\n本页逐项列出公开符号。函数条目保留源码已有的完整签名与契约，补充未独立文档化的基础接口；签名中的类型均相对于当前子模块。源码链接可用于核对该方法的精确重载。\n',
      '\n## 符号索引\n', '| 符号 | 说明位置 |\n|---|---|']
    for k in names:
        if scope=='algorithms' and k in core:
            out.append(f'| `{k}` | [与 MPSCore 相同](core-reference.md#{anchor(k)}) |')
        else:out.append(f'| `{k}` | [逐项参考](#{anchor(k)}) |')
    for k in names:
        if scope=='algorithms' and k in core:continue
        out += ['\n',f'<a id="{anchor(k)}"></a>\n',f'## `{k}`\n']
        if k in manual:
            sig,body=manual[k];out += [f'```julia\n{sig}\n```\n',body+'\n']
        seen=set()
        for p,line,body in blocks[k]:
            if body in seen:continue
            seen.add(body)
            out += ['\n'+clean(body)+'\n',f'\n源码：[{p.relative_to(root)}:{line}](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/{p.relative_to(root)}#L{line})\n']
        if not blocks[k] and k not in manual:raise RuntimeError('Missing documentation: '+k)
        if defs[k]:
            # Include source declarations when docstrings only describe the type or do not list a callable signature.
            lines=list(dict.fromkeys(x[2] for x in defs[k]))
            if not blocks[k] or not any(re.search(re.escape(k)+r'\(',b) for _,_,b in blocks[k]):
                out += ['\n实际声明（类型参数与关键字默认值以源码为准）：\n','```julia\n'+'\n'.join(lines[:8])+'\n```\n']
    path.write_text('\n'.join(out))
write(root/'docs/api/core-reference.md','MPSCore 逐项 API 参考',core,'core',
'''\n导入方式：`import MOSSQuantumMPS.MPSCore as C`。这是数值张量网络基础层，`CanonicalMPS` 不是模拟器外层的 `MOSSQuantumMPS.MPS`。MPS 张量轴序 `(左键,物理,右键)`，MPO 轴序 `(左键,输出物理,右键,输入物理)`。正则链的 `scaling` 是每站点尺度，网络整体带 `scaling^L`。\n
```julia
import MOSSQuantumMPS.MPSCore as C
using LinearAlgebra
psi = C.prodmps(ComplexF64, [2, 2], [1, 1]) # 局域状态索引从 1 开始
@assert norm(psi) ≈ 1
u, s, vt, err = C.tsvd([1.0 0; 0 0.5]; trunc=C.NoTruncation())
@assert u * Diagonal(s) * vt ≈ [1.0 0; 0 0.5]
```
''')
write(root/'docs/api/algorithms-reference.md','MPSAlgorithms 逐项 API 参考',alg,'algorithms',
'''\n导入方式：`import MOSSQuantumMPS.MPSAlgorithms as A`。公共基础类型与 `MPSCore` 的对象相同；索引表将再导出项链接到基础层参考。算法新增项在下方分别列出；`experimental/` 来源的条目属于实验接口。\n
`SVDCompression` 通常返回压缩后的对象；反复扫描的算术算法一般返回 `(对象, ALSConvergenceInfo)`，DMRG 返回值请查具体方法，不能以一种返回形状代替全部重载。收敛状态、残差、截断与内存限制均应随结果核查。\n
```julia
import MOSSQuantumMPS.MPSAlgorithms as A
psi = A.prodmps(ComplexF64, [2, 2], [1, 1])
compressed = A.compress(psi, A.SVDCompression(trunc=A.NoTruncation()))
```

局域维不必为 2。数值基础的 `Gate` 与核心 MOSSQuantum 的线路门是不同对象，矩阵与站点约定以本模块条目为准。\n''')
print('MPSCore exports:',len(core),'MPSAlgorithms exports:',len(alg),'unique submodule symbols:',len(allnames))
for p in (root/'docs/api').glob('*reference.md'):print(p,len(p.read_text().splitlines()),p.stat().st_size)

write(root/'docs/api/models-reference.md','Models 逐项 API 参考',models,'models',
    '导入 `import MOSSQuantumMPS.MPSAlgorithms.Models as Models`。以下模型均为有限开放链，构造函数要求 `L ≥ 2`，不提供周期边界。')
