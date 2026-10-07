#!/usr/bin/env python3
"""Build the Dolby module without bundling firmware binaries."""
from pathlib import Path
import hashlib
import shutil
import subprocess
import zipfile

ROOT = Path(__file__).resolve().parent

def sha(data):
    return hashlib.sha256(data).hexdigest()

def require_hash(data, expected, label):
    actual = sha(data)
    if actual != expected:
        raise ValueError(f"{label}: unexpected SHA256 {actual}")

def stage_files(names):
    stage = ROOT / '.build/module'
    if stage.exists():
        shutil.rmtree(stage)
    stage.mkdir(parents=True)
    for name in names:
        dest = stage / name
        dest.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(ROOT / name, dest)
    for name in ('service.sh', 'customize.sh'):
        subprocess.run(['sh', '-n', str(stage / name)], check=True)
    return stage

def archive(stage, name):
    dest = ROOT / 'dist' / name
    dest.parent.mkdir(exist_ok=True)
    with zipfile.ZipFile(dest, 'w', zipfile.ZIP_DEFLATED, compresslevel=9) as z:
        for path in sorted(stage.rglob('*')):
            if not path.is_file():
                continue
            rel = path.relative_to(stage).as_posix()
            info = zipfile.ZipInfo(rel, (2026, 10, 6, 0, 0, 0))
            info.compress_type = zipfile.ZIP_DEFLATED
            mode = 0o755 if rel.endswith('.sh') or rel == 'bin/frida-inject' else 0o644
            info.external_attr = (0o100000 | mode) << 16
            z.writestr(info, path.read_bytes())
    digest = sha(dest.read_bytes())
    dest.with_suffix('.zip.sha256').write_text(f'{digest}  {dest.name}\n')
    print(dest)
    print('SHA256', digest)

def main():
    stage = stage_files(['module.prop', 'service.sh', 'customize.sh',
                         'README.md', 'CHANGELOG.md', 'LICENSE', 'NOTICE.md',
                         'build.py', 'scripts/patch_karat_aparam.py',
                         'scripts/patch_karat_aparam.sh', 'scripts/recovery.sh'])
    subprocess.run(['sh', '-n', str(stage/'scripts/patch_karat_aparam.sh')], check=True)
    subprocess.run(['sh', '-n', str(stage/'scripts/recovery.sh')], check=True)
    archive(stage, 'firetv-dolby-passthrough-v0.3.2.zip')

if __name__ == '__main__':
    main()
