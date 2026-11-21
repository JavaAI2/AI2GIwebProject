package jp.kurologi.repository;

import java.sql.Connection;
import java.sql.PreparedStatement;

import jp.kurologi.model.PostDTO;
import util.DBmanager;

/**
 * 관리자용 공지사항 수정/삭제 DAO.
 * 목록 · 상세 · 등록은 PostDAO(selectList / selectOne / nextId / insert)를 그대로 쓴다.
 * 회원 본인용 PostDAO.update / delete 는 "작성자 본인" 조건이 붙어 있어서, 관리자용은 여기에 따로 둔다.
 * 공지사항(BOARD_TYPE = 'NOTICE')만 다룬다.
 */
public class AdminNoticeDAO {

	/** 공지 수정(제목, 내용, 수정일). 성공하면 1, 없는 공지면 0 */
	public int update(PostDTO dto) {

		String sql = "UPDATE COMMUNITY_POST SET TITLE = ?, CONTENT = ?, UPDATED_AT = SYSDATE "
				+ "WHERE POST_ID = ? AND BOARD_TYPE = 'NOTICE'";

		try (Connection conn = DBmanager.getInstance();
				PreparedStatement pstmt = conn.prepareStatement(sql)) {
			pstmt.setString(1, dto.getTitle());
			pstmt.setString(2, dto.getContent());
			pstmt.setLong(3, dto.getPostId());
			return pstmt.executeUpdate();
		} catch (Exception e) {
			e.printStackTrace();
		}
		return 0;
	}

	/** 공지 삭제. 성공하면 1, 없는 공지면 0 */
	public int delete(long postId) {

		String sql = "DELETE FROM COMMUNITY_POST WHERE POST_ID = ? AND BOARD_TYPE = 'NOTICE'";

		try (Connection conn = DBmanager.getInstance();
				PreparedStatement pstmt = conn.prepareStatement(sql)) {
			pstmt.setLong(1, postId);
			return pstmt.executeUpdate();
		} catch (Exception e) {
			e.printStackTrace();
		}
		return 0;
	}
}