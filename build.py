#!/usr/bin/env python3
"""Build the tested Dolby module from source and a local stock Karat utility."""
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
    import argparse
    from scripts.patch_karat_aparam import patch
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--karat-aparam', required=True, type=Path,
                        help='Local stock /system/bin/aparam from the supported Karat firmware')
    args = parser.parse_args()
    patched = patch(args.karat_aparam.read_bytes())
    stage = stage_files(['module.prop', 'service.sh', 'customize.sh',
                         'README.md', 'CHANGELOG.md', 'LICENSE', 'NOTICE.md',
                         'build.py', 'scripts/patch_karat_aparam.py'])
    (stage / 'payload').mkdir()
    (stage / 'payload/aparam-karat').write_bytes(patched)
    archive(stage, 'firetv-dolby-passthrough-v0.3.0.zip')

if __name__ == '__main__':
    main()
