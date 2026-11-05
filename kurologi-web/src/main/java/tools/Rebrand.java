package tools;

import java.io.IOException;
import java.nio.charset.MalformedInputException;
import java.nio.charset.StandardCharsets;
import java.nio.file.FileVisitResult;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.SimpleFileVisitor;
import java.nio.file.attribute.BasicFileAttributes;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * 브랜드 이름 · 안내 문구 일괄 정리 도구 : 화면에 보이는 "KURO Logi / KURO / 쿠로" 를 "NIPPON BUY / 니폰바이" 로 바꾸고,
 * 없앤 기능(카카오톡 상담 등)을 가리키던 안내 문구와 외부 링크도 함께 정리한다. (규칙은 아래 EXACT 목록)
 *
 * 사용법 (이클립스)
 *   1) 이 파일을 우클릭 -> Run As -> Java Application   (프로젝트 폴더 기준으로 src 와 sql 을 처리)
 *   2) 먼저 어떤 파일이 바뀌는지만 보고 싶으면 : Run Configurations -> Arguments 에 --dry-run 입력
 *   3) 다른 폴더를 처리하려면 Arguments 에 폴더 경로를 적는다.
 *   4) 실행 뒤에는 git 에서 바뀐 파일을 확인하고, 마음에 안 들면 되돌리면 된다.
 *
 * 바꾸지 않는 것 (기능이 깨지지 않도록)
 *   - 패키지 jp.kurologi, 테이블 KURO_MEMBER, 접속 주소 /kurologi/..., 이미지 파일 이름(kuro_info.jpg 등) 같은 "기술 이름"
 *   - 이 도구 자신(Rebrand.java), .git, 이미지(images), lib 폴더
 *
 * 여러 번 실행해도 결과가 같다. (이미 바뀐 곳은 건드리지 않음)
 */
public class Rebrand {

	private static final String NEW_EN = "NIPPON BUY";
	private static final String NEW_KO = "니폰바이";

	/** 문장 전체를 바꿔야 하는 곳 (기존 문장은 KURO 라는 이름의 뜻을 설명하고 있어서 단어만 바꾸면 말이 안 된다) */
	private static final String[][] EXACT = {
		{ "일본에서 KUROJI(黒字, 쿠로지)는 기업의 흑자를 의미합니다.", "NIPPON(日本)은 일본, BUY는 구매를 뜻합니다." },
		{ "[우리의 물류서비스를 이용하시는 고객사 모두가 「계속 흑자 기업」이되도록", "[일본의 좋은 상품을 한국 고객에게 가장 안전하고 빠르게 전달한다]" },
		{ "최고의 서포트를 한다.] 라는 미션을 배경으로 KURO Logi가 탄생 하였습니다.", "라는 미션을 배경으로 NIPPON BUY가 탄생 하였습니다." },
		// 푸터의 일본어 문구를 한국어로 (링크는 그대로 둔다)
		{ "特定商取引法に基づく表示", "특정상거래법에 따른 표기" },
		{ "個人情報保護方針", "개인정보 보호방침(일본)" },
		// 연락처 이메일 : 도메인을 nipponbuy.jp 로 통일 (예전 값 support@nipponbuy.example 도 같이 정리)
		{ "support@kurologi.jp", "support@nipponbuy.jp" },
		{ "support@nipponbuy.example", "support@nipponbuy.jp" },
		// 카카오톡 상담을 없앴으므로 안내 문구도 1:1 문의 기준으로 정리
		{ "제품 상세사진 카톡채널로 제공", "제품 상세사진은 1:1 문의로 제공" },
		{ "(※카톡 연락으로는 적용되지 않습니다)", "(※1:1 문의로는 적용되지 않습니다)" },
		{ "문의사항은 카톡체널, 1:1게시판으로 연락 바랍니다.", "문의사항은 1:1게시판으로 연락 바랍니다." },
		{ "카카오톡 채널을 통해 전달드립니다", "1:1 문의를 통해 전달드립니다" },
		// 마이페이지 : 알림톡은 쓰지 않으므로 SMS 수신동의만 남긴다
		{ "SMS/카카오알림톡 수신동의", "SMS 수신동의" },
		// ---- 회사 정보 (푸터) : 원래 운영사의 실제 정보 -> 연습용 임의 값 (긴 문장을 먼저 바꾼다) ----
		{ "KURO Logi ( USPbrain Co., Ltd ) / WTKOREA", "NIPPON BUY Co., Ltd" },
		{ "NIPPON BUY ( USPbrain Co., Ltd ) / WTKOREA", "NIPPON BUY Co., Ltd" },
		{ "3F, 1-466-19,  Suzukicho, Kodaira Shi, Tokyo To, 187-0011, Japan", "3F, 1-2-3, Sample-cho, Chiyoda-ku, Tokyo To, 100-0000, Japan" },
		// ---- 일본 센터 주소 · 우편번호 · 전화번호 (홈 화면, 나의 일본주소, MailboxCenter.java) : 임의 값 ----
		{ "福岡県糟屋郡粕屋町仲原２７７４−６ KURO", "福岡県糟屋郡サンプル町7-8-9 NIPPON BUY" },
		{ "福岡県糟屋郡粕屋町仲原２７７４−６ NIPPON BUY", "福岡県糟屋郡サンプル町7-8-9 NIPPON BUY" },
		{ "福岡県 福岡市 博多区 昭南町 2-3-8-3F", "福岡県福岡市中央区サンプル町4-5-6 NIPPON BUY 3F" },
		{ "東京都小平市鈴木町1-466-19-3F", "東京都千代田区サンプル町1-2-3 NIPPON BUY 3F" },
		{ "187-0011", "100-0000" },
		{ "812-0876", "810-0000" },
		{ "811-2304", "811-0000" },
		{ "042-401-0754", "03-1234-5678" },
		{ "070-9293-9189", "092-123-4567" },
		{ "070-9285-4145", "092-234-5678" },
		// ---- 홈 화면 긴급 안내 팝업 : 원래 운영사의 스마트스토어 공지 -> 연습용 안내 (줄 단위로 바꾼다) ----
		{ "! 긴급 ㅅㅅ", "! 안내" },
		{ "<h2 class=\"popup__title\">-", "<h2 class=\"popup__title\">" },
		{ "스마트스토어<br><span class=\"text-red\">택배사 설정 변경</span> 부탁드립니다!", "NIPPON BUY<br><span class=\"text-red\">오픈 안내</span>를 드립니다!" },
		{ "최근 통관사 변경후, <strong>스마트스토어의 트래킹이 되지 않은</strong><br>문제가 발생하고 있습니다.", "일본 쇼핑몰의 상품을 <strong>구매대행 · 배송대행</strong>으로<br>한국까지 안전하게 받아 보세요." },
		{ "변경 전 (현재 설정)", "STEP 1" },
		{ "롯데글로벌로지스", "일본 쇼핑몰 주문" },
		{ "변경 후 (설정 부탁)", "STEP 2" },
		{ "CJ대한통운", "한국 배송" },
		{ "금일부터 연휴로 스마트스토어 측에서 대응이 안되고 있는 상황입니다.<br>", "회원가입 후 주문서를 등록하면 바로 이용할 수 있습니다.<br>" },
		{ "연휴 끝나는 대로 빠르게 개선하겠습니다.", "문의는 1:1게시판을 이용해 주세요." },
		{ "<a class=\"btn btn--primary\" href=\"#\">자세히 보기 ›</a>", "<a class=\"btn btn--primary\" href=\"<%= ctx %>/service/manual\">자세히 보기 ›</a>" },
		// 안내 페이지의 외부 링크 : 원래 운영사의 Notion 문서 -> nipponbuy.jp 주소
		//   (이 주소의 페이지는 아직 없다. nipponbuy.jp 에 실제로 만들거나, 필요하면 아래 주소만 고치면 된다)
		{ "https://detailed-bubbler-ad0.notion.site/18055852ca8f80efa1d0d89b3d0f9785?pvs=74", "https://nipponbuy.jp/service/insurance" },
		{ "https://detailed-bubbler-ad0.notion.site/9189af3da61f44538b942e3731196286", "https://nipponbuy.jp/service/business-customs" },
	};

	/**
	 * 패턴 규칙. 앞뒤 글자를 확인해서(lookbehind / lookahead) 기술 이름은 건드리지 않는다.
	 *   앞 : 영문/숫자/_ . / @ - 가 아니어야 함        (jp.kurologi, /kurologi/, support@kurologi 제외)
	 *   뒤 : 영문/숫자/_ - 가 아니고 ".영문" 도 아니어야 함 (KURO_MEMBER, kurologi-edu, KURO.devAutoLogin 제외)
	 */
	private static final String NOT_AFTER = "(?<![A-Za-z0-9_./@-])";
	private static final String NOT_BEFORE = "(?![A-Za-z0-9_-])(?!\\.[A-Za-z])";   // 뒤 : 영문/숫자/_/- 이거나 ".영문"(KURO.devAutoLogin 같은 설정 이름)이면 제외
	private static final Pattern KURO_LOGI = Pattern.compile(NOT_AFTER + "[Kk][Uu][Rr][Oo][ \\t]*[Ll][Oo][Gg][Ii]" + NOT_BEFORE);
	private static final Pattern KURO_UPPER = Pattern.compile(NOT_AFTER + "KURO" + NOT_BEFORE);
	private static final Pattern KO_LOGI = Pattern.compile("쿠로로지");
	private static final Pattern KO_CARE = Pattern.compile("쿠로안심케어");
	private static final Pattern KO_KURO = Pattern.compile("쿠로(?!지)");
	private static final Pattern NEED_SPACE = Pattern.compile("NIPPON BUY(?=창고)");

	private static final Set<String> EXTENSIONS = Set.of(".jsp", ".jspf", ".java", ".xml", ".css", ".js", ".html", ".sql", ".properties");   // .md 문서는 일부러 제외 (설명 문장까지 바뀌지 않도록)
	private static final Set<String> SKIP_DIRS = Set.of(".git", ".settings", "build", "target", "node_modules", "lib", "images", "jsppossibleOnGithubpull");
	private static final String SELF = "Rebrand.java";

	public static void main(String[] args) throws IOException {

		boolean dryRun = Arrays.asList(args).contains("--dry-run");
		String rootArg = ".";
		for (String a : args) {
			if (!a.startsWith("--")) {
				rootArg = a;
			}
		}
		Path root = Paths.get(rootArg).toAbsolutePath().normalize();
		System.out.println("처리할 폴더 : " + root + (dryRun ? "   (--dry-run : 파일은 바꾸지 않고 목록만 보여 줍니다)" : ""));

		List<Path> files = new ArrayList<>();
		Files.walkFileTree(root, new SimpleFileVisitor<Path>() {
			@Override
			public FileVisitResult preVisitDirectory(Path dir, BasicFileAttributes attrs) {
				String name = dir.getFileName() == null ? "" : dir.getFileName().toString();
				return (!dir.equals(root) && SKIP_DIRS.contains(name)) ? FileVisitResult.SKIP_SUBTREE : FileVisitResult.CONTINUE;
			}

			@Override
			public FileVisitResult visitFile(Path file, BasicFileAttributes attrs) {
				String name = file.getFileName().toString();
				int dot = name.lastIndexOf('.');
				if (dot >= 0 && EXTENSIONS.contains(name.substring(dot).toLowerCase()) && !name.equals(SELF)) {
					files.add(file);
				}
				return FileVisitResult.CONTINUE;
			}
		});

		int changedFiles = 0, totalHits = 0;
		for (Path file : files) {
			String before;
			try {
				before = Files.readString(file, StandardCharsets.UTF_8);
			} catch (MalformedInputException e) {
				System.out.println("건너뜀(UTF-8 이 아님) : " + root.relativize(file));
				continue;
			}

			int[] hits = new int[1];
			String after = rebrand(before, hits);

			if (!after.equals(before)) {
				changedFiles++;
				totalHits += hits[0];
				System.out.printf("%s  %s  (%d곳)%n", dryRun ? "[변경 예정]" : "[변경]", root.relativize(file), hits[0]);
				if (!dryRun) {
					Files.writeString(file, after, StandardCharsets.UTF_8);   // 줄바꿈(CRLF)은 읽은 그대로 보존된다
				}
			}
		}
		System.out.println("----");
		System.out.printf("검사한 파일 %d개 / %s %d개 / 바뀐 곳 %d군데%n", files.size(), dryRun ? "바뀔 파일" : "바뀐 파일", changedFiles, totalHits);
	}

	/** 한 파일의 문자열에 모든 규칙을 적용한다. hits[0] 에 바뀐 횟수를 더해 준다. */
	static String rebrand(String text, int[] hits) {
		String s = text;
		for (String[] pair : EXACT) {
			s = replaceLiteral(s, pair[0], pair[1], hits);
		}
		s = replaceRegex(s, KURO_LOGI, NEW_EN, hits);
		s = replaceRegex(s, KURO_UPPER, NEW_EN, hits);
		s = replaceRegex(s, KO_LOGI, NEW_KO, hits);
		s = replaceRegex(s, KO_CARE, NEW_KO + " 안심케어", hits);
		s = replaceRegex(s, KO_KURO, NEW_KO, hits);
		s = replaceRegex(s, NEED_SPACE, NEW_EN + " ", hits);   // "NIPPON BUY창고" -> "NIPPON BUY 창고"
		return s;
	}

	private static String replaceLiteral(String s, String from, String to, int[] hits) {
		int idx = s.indexOf(from);
		if (idx < 0) {
			return s;
		}
		StringBuilder sb = new StringBuilder();
		int last = 0;
		while (idx >= 0) {
			sb.append(s, last, idx).append(to);
			hits[0]++;
			last = idx + from.length();
			idx = s.indexOf(from, last);
		}
		return sb.append(s.substring(last)).toString();
	}

	private static String replaceRegex(String s, Pattern p, String to, int[] hits) {
		Matcher m = p.matcher(s);
		StringBuilder sb = new StringBuilder();
		int last = 0;
		while (m.find()) {
			sb.append(s, last, m.start()).append(to);
			hits[0]++;
			last = m.end();
		}
		return sb.append(s.substring(last)).toString();
	}
}
