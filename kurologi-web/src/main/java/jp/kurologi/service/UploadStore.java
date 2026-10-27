package jp.kurologi.service;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.regex.Pattern;

/**
 * 업로드한 상품 이미지를 저장하는 폴더 정보.
 *
 * 왜 프로젝트 폴더(getRealPath) 안이 아닌가?
 *   이클립스는 서버를 Clean / 재배포할 때 배포 폴더를 통째로 지운다. 그 안에 저장하면 사진이 사라진다.
 *   그래서 내 컴퓨터의 사용자 폴더(예: C:\Users\내이름\kurologi-upload\buy)에 저장한다.
 *   다른 위치를 쓰고 싶으면 Tomcat 실행 옵션에 -Dkurologi.upload.dir=D:/upload/buy 를 준다.
 */
public final class UploadStore {

	private UploadStore() { }

	/** DB(IMAGE_URL)에 저장하고 화면에서 불러올 때 쓰는 주소 앞부분 */
	public static final String URL_PREFIX = "/uploads/buy/";

	/** 서버가 만든 파일 이름 형태(랜덤 32자리 + 확장자). 이 모양이 아니면 절대 열어 주지 않는다 */
	public static final Pattern FILE_NAME = Pattern.compile("[0-9a-f]{32}\\.(jpg|png|gif|webp)");

	/** 저장 폴더를 돌려준다. 없으면 만든다 (학원 FileIo 의 mkdirs) */
	public static Path dir() throws IOException {
		String custom = System.getProperty("kurologi.upload.dir");
		Path dir = (custom != null && !custom.trim().isEmpty())
				? Paths.get(custom.trim())
				: Paths.get(System.getProperty("user.home"), "kurologi-upload", "buy");
		Files.createDirectories(dir);
		return dir;
	}

	/**
	 * DB 에 저장된 이미지URL 을 화면의 <img src> 에 써도 안전한 주소로 바꾼다. 안전하지 않으면 "".
	 *   https://... 는 그대로, /uploads/buy/xxx.jpg 는 앞에 프로젝트 주소(ctx)를 붙인다.
	 * (출력할 때는 Html.esc 로 한 번 더 감싸 쓴다)
	 */
	public static String imageSrc(String ctx, String url) {
		if (url == null) {
			return "";
		}
		String u = url.trim();
		String lower = u.toLowerCase();
		if (lower.startsWith("http://") || lower.startsWith("https://")) {
			return u;
		}
		if (u.startsWith(URL_PREFIX) && FILE_NAME.matcher(u.substring(URL_PREFIX.length())).matches()) {
			return ctx + u;
		}
		return "";
	}
}
