package util;

import java.util.List;

import jp.kurologi.model.FaqDTO;
import jp.kurologi.model.PostDTO;
import jp.kurologi.repository.FaqDAO;
import jp.kurologi.repository.PostDAO;

/**
 * 커뮤니티 DAO 가 SQL 오류 없이 동작하는지 확인하는 테스트 (서버 없이 실행).
 * 실행: 이 파일을 열고 우클릭 -> Run As -> Java Application, 아래 Console 에서 결과 확인.
 * 먼저 community_test_seed.sql 로 테스트 데이터를 넣어 두세요.
 */
public class CommunityDaoTest {

	public static void main(String[] args) {

		PostDAO postDao = new PostDAO();

		// 1. 공지사항
		int noticeCount = postDao.selectCount(PostDAO.TYPE_NOTICE, null, null, null);
		System.out.println("[공지] 전체 개수 = " + noticeCount);
		List<PostDTO> notices = postDao.selectList(PostDAO.TYPE_NOTICE, null, null, null, 1, 10);
		for (PostDTO p : notices) {
			System.out.println("  " + p.getPostId() + " | " + p.getTitle() + " | 작성자=" + p.getWriterName()
					+ " | " + p.getCreatedAt() + " | 조회=" + p.getViewCount() + " | N배지=" + p.isNewPost());
		}

		// 2. 검색 (제목에 '테스트' 가 들어간 공지)
		System.out.println("[공지] '테스트' 제목 검색 개수 = "
				+ postDao.selectCount(PostDAO.TYPE_NOTICE, "title", "테스트", null));

		// 3. 상세
		if (!notices.isEmpty()) {
			PostDTO one = postDao.selectOne(notices.get(0).getPostId(), PostDAO.TYPE_NOTICE);
			System.out.println("[공지] 상세 = " + (one == null ? "없음" : one.getTitle() + " / " + one.getContent()));
		}

		// 4. FAQ
		List<FaqDTO> faqs = new FaqDAO().selectAll();
		System.out.println("[FAQ] 개수 = " + faqs.size());
		for (FaqDTO f : faqs) {
			System.out.println("  " + f.getCategory() + " | " + f.getQuestion());
		}
	}
}