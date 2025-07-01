export const handler = async (event) => {
	const forceError = process.env.FORCE_ERROR;

	if (forceError) {
		throw new Error("Forced error");
	}

	const response = {
		statusCode: 200,
		headers: {
			"Content-Type": "application/json",
		},
		body: JSON.stringify({ message: `Hello from ${process.env.AWS_REGION}!` }),
		};
		
	return response;
};
