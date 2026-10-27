package jp.kurologi.web;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import jp.kurologi.service.UploadStore;

/**
 * 업로드한 상품 이미지를 브라우저에 보여 주는 서블릿 (GET /uploads/buy/파일이름)
 * 사진 파일은 프로젝트 밖 폴더에 있으므로, 이 서블릿이 읽어서 내보낸다.
 */
@WebServlet("/uploads/buy/*")
public class UploadFileServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		String pathInfo = request.getPathInfo();   // "/xxxx.jpg"
		String name = (pathInfo == null) ? "" : pathInfo.substring(1);

		// 서버가 만든 이름 형태가 아니면 열어 주지 않는다 ("../" 로 다른 파일을 읽는 공격 차단)
		if (!UploadStore.FILE_NAME.matcher(name).matches()) {
			response.sendError(HttpServletResponse.SC_NOT_FOUND);
			return;
		}

		Path file = UploadStore.dir().resolve(name);
		if (!Files.isRegularFile(file)) {
			response.sendError(HttpServletResponse.SC_NOT_FOUND);
			return;
		}

		String ext = name.substring(name.lastIndexOf('.') + 1);
		String type;
		switch (ext) {
		case "png":  type = "image/png";  break;
		case "gif":  type = "image/gif";  break;
		case "webp": type = "image/webp"; break;
		default:     type = "image/jpeg"; break;
		}

		response.setContentType(type);
		response.setHeader("X-Content-Type-Options", "nosniff");
		response.setHeader("Cache-Control", "public, max-age=86400");
		response.setContentLengthLong(Files.size(file));
		Files.copy(file, response.getOutputStream());
	}
}
