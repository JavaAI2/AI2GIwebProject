package jp.kurologi.repository;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import jp.kurologi.model.CommentDTO;
import util.DBmanager;

/**
 * COMMUNITY_COMMENT 테이블 전용 DAO
 * 1:1게시판에서 관리자의 답변을 보여주는 용도라서 지금은 조회만 있다.
 * (관리자 답변은 SQL 로 등록하고, 등록 후 COMMUNITY_POST.ANSWER_YN 을 'Y' 로 바꿔 준다)
 */
public class CommentDAO {

	/** 글 1건에 달린 댓글 목록 (오래된 것부터). 삭제된 댓글도 포함되니 화면에서 isDeleted() 로 가린다 */
	public List<CommentDTO> selectByPost(long postId) {

		String sql = "SELECT c.COMMENT_ID, c.POST_ID, c.PARENT_ID, c.CONTENT, c.WRITER_ID, m.NAME AS WRITER_NAME, "
				+ "c.DELETED_YN, TO_CHAR(c.CREATED_AT, 'YYYY-MM-DD HH24:MI') AS CREATED_AT "
				+ "FROM COMMUNITY_COMMENT c LEFT JOIN KURO_MEMBER m ON c.WRITER_ID = m.ID "
				+ "WHERE c.POST_ID = ? ORDER BY c.COMMENT_ID";

		List<CommentDTO> list = new ArrayList<>();
		try (Connection conn = DBmanager.getInstance();
				PreparedStatement pstmt = conn.prepareStatement(sql)) {
			pstmt.setLong(1, postId);
			try (ResultSet rs = pstmt.executeQuery()) {
				while (rs.next()) {
					CommentDTO dto = new CommentDTO();
					dto.setCommentId(rs.getLong("COMMENT_ID"));
					dto.setPostId(rs.getLong("POST_ID"));

					long parentId = rs.getLong("PARENT_ID");
					if (!rs.wasNull()) {
						dto.setParentId(parentId);
					}
					dto.setContent(rs.getString("CONTENT"));

					long writerId = rs.getLong("WRITER_ID");
					if (!rs.wasNull()) {
						dto.setWriterId(writerId);
					}
					dto.setWriterName(rs.getString("WRITER_NAME"));
					dto.setDeleted("Y".equals(rs.getString("DELETED_YN")));
					dto.setCreatedAt(rs.getString("CREATED_AT"));
					list.add(dto);
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return list;
	}
}