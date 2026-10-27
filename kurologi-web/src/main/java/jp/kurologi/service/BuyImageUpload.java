package jp.kurologi.service;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.util.UUID;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;

import jp.kurologi.web.Session;

/**
 * 상품 이미지 업로드 (POST /buyorder/upload, multipart)
 * 화면의 [이미지 업로드] 버튼이 Ajax(fetch)로 호출하고, 결과는 JSON 으로 돌려준다.
 *   성공 : {"ok":true,"path":"/uploads/buy/xxxx.jpg"}
 *   실패 : {"ok":false,"message":"..."}
 *
 * 안전을 위해
 *   1) 로그인한 회원만 올릴 수 있고
 *   2) 5MB 까지만 받고
 *   3) 사용자가 정한 파일 이름·확장자는 믿지 않고, 파일 내용(맨 앞 바이트)으로 JPG/PNG/GIF/WEBP 인지 직접 확인하고
 *   4) 저장 이름은 서버가 랜덤(UUID)으로 새로 만든다.
 */
public class BuyImageUpload implements Command {

	private static final long MAX_BYTES = 5L * 1024 * 1024;

	@Override
	public boolean doCommand(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		response.setContentType("application/json;charset=UTF-8");

		if (!"POST".equalsIgnoreCase(request.getMethod())) {
			return error(response, 405, "잘못된 요청입니다.");
		}
		if (Session.memberId(request) == null) {
			return error(response, 401, "로그인 후 이미지를 올릴 수 있습니다.");
		}

		try {
			Part part = request.getPart("file");
			if (part == null || part.getSize() == 0) {
				return error(response, 400, "이미지 파일을 선택해 주세요.");
			}

			byte[] data;
			try (InputStream in = part.getInputStream()) {
				data = in.readNBytes((int) MAX_BYTES + 1);   // 한도보다 1바이트 더 읽어 초과 여부를 확인
			}
			if (data.length > MAX_BYTES) {
				return error(response, 400, "이미지는 5MB 이하만 올릴 수 있습니다.");
			}

			String ext = detectExtension(data);
			if (ext == null) {
				return error(response, 400, "JPG, PNG, GIF, WEBP 이미지만 올릴 수 있습니다.");
			}

			String fileName = UUID.randomUUID().toString().replace("-", "") + "." + ext;
			Files.write(UploadStore.dir().resolve(fileName), data);

			response.getWriter().write("{\"ok\":true,\"path\":\"" + UploadStore.URL_PREFIX + fileName + "\"}");
			return false;

		} catch (IllegalStateException e) {
			// MultipartConfig 의 용량 제한(5MB)을 넘으면 서블릿 컨테이너가 던진다
			return error(response, 400, "이미지는 5MB 이하만 올릴 수 있습니다.");
		} catch (ServletException e) {
			return error(response, 400, "업로드 형식이 올바르지 않습니다.");
		} catch (IOException e) {
			e.printStackTrace();
			return error(response, 500, "이미지를 저장하지 못했습니다. 잠시 후 다시 시도해 주세요.");
		}
	}

	/** 파일 맨 앞 바이트(매직 넘버)로 이미지 종류를 판단한다. 이미지가 아니면 null */
	private static String detectExtension(byte[] d) {
		if (d.length >= 3 && (d[0] & 0xFF) == 0xFF && (d[1] & 0xFF) == 0xD8 && (d[2] & 0xFF) == 0xFF) {
			return "jpg";
		}
		if (d.length >= 8 && (d[0] & 0xFF) == 0x89 && d[1] == 'P' && d[2] == 'N' && d[3] == 'G'
				&& d[4] == 0x0D && d[5] == 0x0A && d[6] == 0x1A && d[7] == 0x0A) {
			return "png";
		}
		if (d.length >= 6 && d[0] == 'G' && d[1] == 'I' && d[2] == 'F' && d[3] == '8'
				&& (d[4] == '7' || d[4] == '9') && d[5] == 'a') {
			return "gif";
		}
		if (d.length >= 12 && d[0] == 'R' && d[1] == 'I' && d[2] == 'F' && d[3] == 'F'
				&& d[8] == 'W' && d[9] == 'E' && d[10] == 'B' && d[11] == 'P') {
			return "webp";
		}
		return null;   // SVG 는 안에 스크립트를 넣을 수 있어서 일부러 허용하지 않는다
	}

	private boolean error(HttpServletResponse response, int status, String message) throws IOException {
		response.setStatus(status);
		response.getWriter().write("{\"ok\":false,\"message\":\"" + message + "\"}");
		return false;
	}
}
