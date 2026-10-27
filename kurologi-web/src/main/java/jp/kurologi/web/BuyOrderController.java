package jp.kurologi.web;

import java.io.IOException;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import jp.kurologi.service.BuyImageUpload;
import jp.kurologi.service.BuyOrderDelete;
import jp.kurologi.service.BuyOrderForm;
import jp.kurologi.service.BuyOrderInsert;
import jp.kurologi.service.BuyOrderList;
import jp.kurologi.service.BuyOrderView;
import jp.kurologi.service.Command;

/**
 * /buyorder/* 로 들어오는 구매대행 요청을 받는 컨트롤러
 *
 *   /buyorder/form     주문서 입력 화면 (GET, id 가 있으면 수정)  -> BuyOrderForm   -> order_form.jsp
 *   /buyorder/save     주문서 저장 / 수정 (POST)                  -> BuyOrderInsert (실패하면 order_form.jsp)
 *   /buyorder/list     내 주문 목록 (GET)                         -> BuyOrderList   -> order_list.jsp
 *   /buyorder/view     주문 상세 (GET)                            -> BuyOrderView   -> order_view.jsp
 *   /buyorder/delete   접수대기 주문 삭제 (POST)                  -> BuyOrderDelete
 *   /buyorder/upload   상품 이미지 업로드 (POST, Ajax)            -> BuyImageUpload (파일을 받으므로 @MultipartConfig 필요)
 *
 * 흐름 : 컨트롤러(주소 판단) -> Command(실제 처리) -> DAO(DB) -> (true 이면) JSP forward
 */
@WebServlet("/buyorder/*")
@MultipartConfig(fileSizeThreshold = 1024 * 1024, maxFileSize = 5L * 1024 * 1024, maxRequestSize = 6L * 1024 * 1024)
public class BuyOrderController extends HttpServlet {
	private static final long serialVersionUID = 1L;

	private static final String VIEWS = "/WEB-INF/views/buy/";

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		doAction(request, response);
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		doAction(request, response);
	}

	protected void doAction(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		// 파라미터를 읽기 전에 먼저 지정해야 한글이 깨지지 않는다
		request.setCharacterEncoding("UTF-8");

		String pathInfo = request.getPathInfo();   // /buyorder/save 이면 "/save"
		if (pathInfo == null) {
			pathInfo = "";
		}

		Command command = null;
		String page = null;   // null 이면 Command 가 redirect / JSON 으로 응답을 끝낸다

		switch (pathInfo) {

		case "/form":
			command = new BuyOrderForm();
			page = VIEWS + "order_form.jsp";
			break;

		case "/save":
			command = new BuyOrderInsert();
			page = VIEWS + "order_form.jsp";   // 검사에 실패하면 입력값을 담아 이 화면으로
			break;

		case "/list":
			command = new BuyOrderList();
			page = VIEWS + "order_list.jsp";
			break;

		case "/view":
			command = new BuyOrderView();
			page = VIEWS + "order_view.jsp";
			break;

		case "/delete":
			command = new BuyOrderDelete();
			break;

		case "/upload":
			command = new BuyImageUpload();
			break;

		default:
			response.sendError(HttpServletResponse.SC_NOT_FOUND);
			return;
		}

		boolean needForward = command.doCommand(request, response);

		if (needForward && page != null) {
			RequestDispatcher rd = request.getRequestDispatcher(page);
			rd.forward(request, response);
		}
	}
}
