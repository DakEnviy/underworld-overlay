#!/usr/bin/env python3
'''Script to update yandex-browser-beta ebuild file.

Dependencies:
    beautifulsoup4: For repository scrapping
    packaging: For version parsing
    python-debian: For working with .deb packages
    requests: For HTTP requests
'''

import re
import io
from pathlib import Path

try:
    from bs4 import BeautifulSoup
except ImportError:
    print('Error: beautifulsoup4 module not found. Install with: pip install beautifulsoup4')
    exit(1)

try:
    from packaging import version as pkg_version
except ImportError:
    print('Error: packaging module not found. Install with: pip install packaging')
    exit(1)

try:
    import requests
except ImportError:
    print('Error: requests module not found. Install with: pip install requests')
    exit(1)

try:
    from debian import debfile
except ImportError:
    print('Error: python-debian module not found. Install with: pip install python-debian')
    exit(1)

SCRIPT_DIR = Path(__file__).parent.resolve()
OVERLAY_DIR = SCRIPT_DIR.parent
EBUILD_DIR = OVERLAY_DIR / 'www-client' / 'yandex-browser-beta'
YANDEX_URL = 'https://repo.yandex.ru/yandex-browser/deb/pool/main/y/yandex-browser-beta/'


def get_latest_version() -> tuple[str, str | None]:
    '''Get latest yandex-browser-beta version from repository.'''
    response = requests.get(YANDEX_URL)
    response.raise_for_status()

    soup = BeautifulSoup(response.text, 'html.parser')
    deb_links = [str(a['href']) for a in soup.find_all('a', href=True) if str(a['href']).endswith('.deb')]

    if not deb_links:
        raise ValueError('No .deb files found')

    pattern = r'yandex-browser-beta_([0-9.]+-[0-9]+)_amd64\.deb'
    versions = []
    for link in deb_links:
        match = re.search(pattern, link)
        if match:
            versions.append(match.group(1))

    if not versions:
        raise ValueError('No versions found in .deb links')

    sorted_versions = sorted(versions, key=pkg_version.parse)
    version = sorted_versions[-1].split('-', maxsplit=2)
    return (version[0], version[1] if len(version) > 1 else None)


def get_current_ebuild() -> Path:
    '''Get current latest ebuild file.'''
    ebuild_files = list(EBUILD_DIR.glob('*.ebuild'))
    if not ebuild_files:
        raise ValueError('No ebuild files found')

    return max(ebuild_files, key=lambda p: pkg_version.parse(p.stem.replace('yandex-browser-beta-', '').replace('_rc', '.')))


def parse_ebuild_version(ebuild_path: Path) -> tuple[str, str | None]:
    '''Parse version and RC suffix from ebuild filename.'''
    name = ebuild_path.stem
    match = re.match(r'^yandex-browser-beta-([0-9.]+)(?:_rc(\d+))?$', name)
    if not match:
        raise ValueError(f'Cannot parse version from {name}')

    return (match.group(1), match.group(2))


def fetch_ffmpeg_version(deb_data: bytes) -> str:
    '''Extract FFmpeg version from deb file (in memory).'''
    with io.BytesIO(deb_data) as deb_io:
        with debfile.DebFile(fileobj=deb_io) as deb:
            content = deb.data.get_content('/opt/yandex/browser-beta/update-ffmpeg')
            if content is None:
                raise ValueError('File update-ffmpeg not found in deb file')
            content_str = content.decode('utf-8', errors='ignore')
            match = re.search(r'(\d+)\.\d+\.\d+', content_str)
            if match:
                return match.group(1)
    raise ValueError('FFmpeg version not found in update-ffmpeg')


def download_deb(version: str) -> bytes:
    '''Download deb file and return its content.'''
    url = f'{YANDEX_URL}yandex-browser-beta_{version}_amd64.deb'
    return requests.get(url).content


def generate_ebuild(template_path: Path, ffmpeg_pv: str) -> str:
    '''Generate new ebuild content from template.'''
    content = template_path.read_text()
    content = re.sub(r'^FFMPEG_PV="[^"]+"', f'FFMPEG_PV="{ffmpeg_pv}"', content, flags=re.MULTILINE)
    return content


def format_version(ver: str, separator: str) -> str:
    '''Format version tuple with separator.'''
    return f'{ver[0]}{separator}{ver[1]}' if len(ver) > 1 else ver[0]


def format_ebuild_version(ver: str) -> str:
    return format_version(ver, '_rc')


def format_deb_version(ver: str) -> str:
    return format_version(ver, '-')


def main() -> None:
    '''Main function.'''
    print('Getting latest version from repository...')
    latest_version = get_latest_version()
    latest_deb_version = format_deb_version(latest_version)
    print(f'Latest version on FTP: {latest_deb_version}')

    print('\nGetting current ebuild...')
    current_ebuild = get_current_ebuild()
    current_version = parse_ebuild_version(current_ebuild)
    current_deb_version = format_deb_version(current_version)
    print(f'Current version: {current_deb_version}')

    if latest_version == current_version:
        print('\nAlready up to date')
        return

    print(f'\nUpdating from {current_deb_version} to {latest_deb_version}')

    print('\nDownloading deb file...')
    deb_data = download_deb(latest_deb_version)

    print('Extracting FFmpeg version...')
    ffmpeg_pv = fetch_ffmpeg_version(deb_data)
    print(f'FFmpeg version: {ffmpeg_pv}')

    new_ebuild_name = f'yandex-browser-beta-{format_ebuild_version(latest_version)}.ebuild'
    new_ebuild_path = EBUILD_DIR / new_ebuild_name

    print(f'\nGenerating new ebuild: {new_ebuild_name}')

    new_content = generate_ebuild(current_ebuild, ffmpeg_pv)

    if new_ebuild_path.exists():
        if new_ebuild_path.read_text() == new_content:
            print('ebuild already up to date')
            return
        print(f'Warning: overwriting existing file {new_ebuild_path}')

    new_ebuild_path.write_text(new_content)
    print(f'New ebuild created: {new_ebuild_path}')


if __name__ == '__main__':
    main()
